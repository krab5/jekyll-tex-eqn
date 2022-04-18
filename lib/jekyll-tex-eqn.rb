# Copyright 2022 krab5
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy 
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
# copies of the Software, and to permit persons to whom the Software is 
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all 
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
# SOFTWARE.
####


# This sole module contains everything needed to perform the tasks provided by
# the plug-in. In particular, it contains:
#   - A few utility classes
#   - Liquid tags and blocks
# It also makes the necessary registration for working with Jekyll

require "jekyll"
require "fileutils"
require "digest"                # Needed for generating unique file names

module Jekyll
  # Main module for the plug-in
  module JekyllTexEqn
    # Utility class, with a few constants and class methods, mostly to retrieve
    # options and to report errors
    class Util
      ROOT="texeqn"                           # YAML tag for this plugin's options
      BACKEND_KEY="backend"                   # Key for backend configuration
      OPTIONS_KEY="options"                   # Key for extra options for the backend
      PACKAGES_KEY="packages"                 # Key for the package list
      EXTRAPACKAGES_KEY="extra_packages"      # Key for the extra package list
      TMPDIR_KEY="tmpdir"                     # Key for the temporary directory
      OUTPUTDIR_KEY="outputdir"               # Key for the output directory
      INLINE_CLASS_KEY="inlineclass"          # Key for the inline equation class configuration
      BLOCK_CLASS_KEY="blockclass"            # Key for the block equation class configuration
      EXTRAHEAD_KEY="extra_head"              # Key for the extra header
      INLINE_SCALE_KEY="inline_scale"         # Key for setting up image scaling for inline equations
      BLOCK_SCALE_KEY="block_scale"           # Key for setting up image scaling for block equations
  
      # Default values
      DEFAULT_BACKEND="pdflatex"
      DEFAULT_PACKAGES= [
        {"name": "inputenc", "option": "utf8"},
        {"name": "fontenc",  "option": "T1"},
        {"name": "amsmath"},
        {"name": "amssymb"}
      ]
      DEFAULT_TMPDIR="_tmp"
      DEFAULT_OUTPUTDIR="assets/texeqn"
      DEFAULT_INLINE_SCALE="2.4"
      DEFAULT_BLOCK_SCALE="2.4"

      # Retrieve Jekyll configuration for this plugin
      @@config = Jekyll.configuration({})[ROOT]

      # Get the value of an option, or the provided default value if that option
      # has not been set
      def self.get_option(key, default)
        v = @@config[key]
        if v.nil? && !default.nil? then
          v = default
        end
        v
      end

      # Make an error message to be reported
      def self.report(context, msg, cause)
        err = ""
        if !context.nil? then
          thispage = context.registers[:page]['path']
          err = "On #{thispage}: "
        end
        err << msg
        if !cause.nil? && !cause.message.empty? then
          err << ": #{cause.message}"
        end
        err
      end
    end

    # Tool-class for doing all the SVG generation
    class Generate
      @@basedir = Util.get_option(Util::TMPDIR_KEY, Util::DEFAULT_TMPDIR)
      @@outdir = Util.get_option(Util::OUTPUTDIR_KEY, Util::DEFAULT_OUTPUTDIR)
      @@backend = Util.get_option(Util::BACKEND_KEY, Util::DEFAULT_BACKEND)
      @@options = Util.get_option(Util::OPTIONS_KEY, []).join(" ")

      # This is the PDF command. The provided options are mandatory for smooth
      # running:
      #   * "-halt-on-error" means LaTeX will exit upon error, instead of 
      #   asking the user to provide a solution
      #   * "-interaction nonstopmode" remove any form of interaction with
      #   LaTeX
      #   * "-file-line-error" put the file name and the line number for errors
      #   (better for debugging your code)
      #   * "--jobname=output" means the result of LaTeX will be named
      #   "output.pdf"; this makes things easier during the process
      @@pdf = "#{@@backend} -halt-on-error -interaction nonstopmode -file-line-error --jobname=output #{@@options}"

      # Run the set of commands that perform the conversion from TeX to SVG
      # This takes as argument "basedir", the directory where TeX files are
      # located, and "base" the basename of the .tex file to process (more
      # convenient when browsing directory). Also takes "outdir", the directory
      # where to export the SVG, and "pdf", the pdfxx command that performs the
      # TeX => PDF conversion (easier because then this value is calculated only
      # once).
      def self.run_cmd(base)
        text = ""

        # Cleanup if needed (in case of past error for instanec)
        if !File.exists?("#{@@basedir}/#{base}") then
          Dir.mkdir("#{@@basedir}/#{base}")
        end

        # Run pdfxx, compile TeX into PDF
        text = %x|#{@@pdf} -output-directory=#{@@basedir}/#{base}/ #{@@basedir}/#{base}.tex 2>&1|
        if $?.exitstatus != 0 then
          raise "[#{base}] Error #{$?.exitstatus} while executing backend:\n#{text}"
        end

        # Use pdfcrop to crop the PDF
        text = %x|pdfcrop #{@@basedir}/#{base}/output.pdf #{@@basedir}/#{base}/output-crop.pdf 2>&1|
        if $?.exitstatus != 0 then
          raise "[#{base}] Error #{$?.exitstatus} while croping PDF:\n#{text}"
        end
        
        # Use pdf2svg to transform the cropped PDF into an SVG
        text = %x|pdf2svg #{@@basedir}/#{base}/output-crop.pdf #{@@outdir}/#{base}.svg 2>&1|
        if $?.exitstatus != 0 then
          raise "[#{base}] Error #{$?.exitstatus} while generating SVG:\n#{text}"
        end

      end
      
      # Build a file name where the code will be stored, based on the "host"
      # file path (i.e. file where the equation is located) and the equation's
      # content.
      # The filename is generated by making sure there are no spaces, and using
      # a hash function on the content to obtain (virtually) unique names.
      def self.filename(filepath, content)
        id = Digest::MD5.hexdigest content
        pagepath = filepath
        pagepath.gsub("/", "_").gsub(" ", "-")
        "#{pagepath}-#{id}"
      end
  
      # Generate a tex file from the given content, using the provided equation
      # environment opener and closer (e.g. \[-\], \begin{equation}-\end{equation}, etc.)
      def self.generate_file(context, content, begineqn, endeqn, file)
        text =  "\\documentclass{minimal}\n"
        pkgs = Util.get_option(Util::PACKAGES_KEY, Util::DEFAULT_PACKAGES)
        pkgs.concat Util.get_option(Util::EXTRAPACKAGES_KEY, [])
        for p in pkgs do
          text << "\\usepackage"
          if p.include?(:option) then
            text << '[' << (p[:option].nil? ? p['option'] : p[:option]) << ']'
          end
          text << '{' << (p[:name].nil? ? p['name'] : p[:name]) << '}' << "\n"
        end
  
        text << Util.get_option(Util::EXTRAHEAD_KEY, "")
        text << "\n\\begin{document}\n"
        text << begineqn 
        text << content
        text << endeqn << "\n"
        text << "\\end{document}\n"
  
        begin
          File.open(file, 'w') { |f|
            f.write text
          }
        rescue => e
          raise Util.report(context, "error while creating tex file '#{file}'", e)
        end
      end

      # Perform a full rendering step, i.e. create the Tex file, compile, crop and transform
      # into an SVG
      def self.do_render(context, content, scale, begineqn, endeqn)
        content.strip!
        path = context.registers[:page]['path']
        file = Generate.filename(path, content)
        texfile = "#{@@basedir}/#{file}.tex"
        svgfile = "#{@@outdir}/#{file}.svg"

        # If the SVG file already exists, no need to re-render it (usually)
        # If the TeX file already exists, this usually mean something went wrong and it is
        # erroneous!
        if !File.exists?(texfile) && !File.exists?(svgfile) then
          Jekyll.logger.info("Generating image file #{file}")
          Generate.generate_file(context, content, begineqn, endeqn, texfile)
          Generate.run_cmd(file)
          File.delete(texfile)
          if File.exists?("#{@@basedir}/#{file}") then
            FileUtils.remove_dir("#{@@basedir}/#{file}")
          end
        end

        # Retrieve SVG dimensions
        svghead = File.readlines(svgfile)[1]
        width = svghead[/width="(\d+)[a-z]+"/,1]
        height = svghead[/height="(\d+)[a-z]+"/,1]

        { file: svgfile, width: width.to_f * scale, height: height.to_f * scale } # Dimensions are scaled
      end
    end

    # Liquid tag for inline equations
    class RenderTexTag < Liquid::Tag
      TAGNAME="ieqn"

      def initialize(tagname, text, tokens)
        super
        @content = text
        @content.chomp
      end

      def render(context)
        svg = Generate.do_render(context, @content, Util.get_option(Util::INLINE_SCALE_KEY, Util::DEFAULT_INLINE_SCALE).to_f, "$", "$")
        "<span class='#{Util.get_option(Util::INLINE_CLASS_KEY, "")}'><img width='#{svg[:width]}px' height='#{svg[:height]}px' src='/#{svg[:file]}'/></span>"
      end
    end

    # Liquid block for block equations
    class RenderTexBlock < Liquid::Block
      TAGNAME="eqn"

      def render(context)
        content = super
        svg = Generate.do_render(context, content, Util.get_option(Util::BLOCK_SCALE_KEY, Util::DEFAULT_BLOCK_SCALE).to_f, "\\begin{displaymath}\n", "\n\\end{displaymath}")
        "<div class='#{Util.get_option(Util::BLOCK_CLASS_KEY, "")}'><img width='#{svg[:width]}px' height='#{svg[:height]}px' src='/#{svg[:file]}'/></div>"
      end
    end
  end

  Liquid::Template.register_tag(JekyllTexEqn::RenderTexBlock::TAGNAME, JekyllTexEqn::RenderTexBlock)
  Liquid::Template.register_tag(JekyllTexEqn::RenderTexTag::TAGNAME, JekyllTexEqn::RenderTexTag)
end



