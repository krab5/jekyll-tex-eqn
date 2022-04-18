# Jekyll TeX Equation Processor

_Static, JS-free, SVG equations for your Jekyll website!_


## Introduction

Nowadays, if you want to include equations in a web page (e.g. because you're a
NERD) you need to either use MathJax or MathML.

The problem with MathJax is that it uses JavaScript; meanwhile, MathML is an
okay standard but is not set and does not provide every features one could want
for their beautiful equations and other nerdy stuff.

Since I wanted beautiful equations for my Jekyll sites, I came up with a
solution. No the best, but probably good enough.

> "Alas! If only there existed some kind of rendering engine associated to a
> simple language anybody doing maths and other such things could know..."
> -- me, c.a. 2022 (dramatic reenactment)

<br>

The main idea of this Jekyll plug-in is to provide equation rendering for pages,
based on LaTeX. This takes advantage from the fact that the site is statically 
generated anyway, and that LaTeX is easily available, quite extensible and 
extremely powerful.

Below is the documentation of the plug-in. You will also find a simple example
site in the `example` subdirectory.



## Installation and Requirements

This plug-in requires:
 * A working version of LaTeX (with PDFLaTeX, XeTeX, or LuaTeX, whichever)
 * A few LaTeX packages, especially for math stuff (by default, `amsmath` and
   `amssymb`, usually distributed with LaTeX)
 * [`pdfcrop`](https://github.com/ho-tex/pdfcrop) for cropping PDF, distributed 
   with TeXLive an MikTeX or most probably available as a package for your
   favourite distro (e.g. `texlive-extra-utils` for Debian/Ubuntu)
 * [`pdf2svg`](https://github.com/dawbarton/pdf2svg) for transforming PDF to
   SVG, also most probably available as a package for your favourite distro

To install the plug-in, simply add it to your `Gemfile` as any other plug-in.


## Added Tags

This plug-in adds two Liquid tags: one block/environment and one in-tag.

### Block Equation Tags

You can write a "block"-style equation using `{% eqn %}...{% endeqn %}`. This
equation will be rendered in a `div`, and is intended to be separated from other
text blocks.

You can write any **math-mode LaTeX code** between the tags. Internally, this
code will be put between `\begin{displaymath}...\end{displaymath}`. The code may
be split on several lines, and you can even use some environments (e.g. `split`,
`array`, etc.).

Example:
```
We define function *f* as follow:
{% eqn %}
f(x) = \left\{\begin{array}{ll}
0 & \quad\text{iff}\:x \leq 0 \\
x^2 & \quad\text{else}
\end{array}\right.
{% endeqn %}
```

### In-line Equation Tag

You can write an in-line equation using the `{% ieqn ... %}` tag. This equation
will be rendered in a `span`, and is intended to be used in text.

Similarly to block equations, you can write any math-mode LaTeX code in the tag,
except that **it will be but between singl dollar ($) signs**. This means in
particular that **you cannot have newline characters**.

Example:
```
We are interested in the derivative of *f* on {% ieqn [0,+\infty) %}, which in
this case is {% ieqn \frac{\text{d} f}{\text{d} x}(x) = 2 x %}.
```


## Configuration

The plug-in is configured in `_config.yml`, under the `texeqn` tag:
```yaml
... other Jekyll stuff ...

texeqn:
    backend: "pdflatex"
    options: "-fmt=pdfetex"
    packages:
      - name: "inputenc"
        option: "utf8"
      - name: "fontenc"
        option: "T1"
    extra_packages:
      - name: "mathtools"
    extra_head: |
      \newcommand{\R}{\mathbb{R}}
      \newcommand{\der}[2]{\frac{\text{d}\,#1}{\text{d}\,#2}}
    tmpdir: "_temporary/texeqn/"
    outputdir: "assets/equations/svg/"
    inlineclass: "eqn eqn-inline"
    blockclass: "eqn eqn-block"
    inline_scale: 1.5
    block_scale: 1.2
```

Most options have a default value, so the plug-in is pretty much usable out of
the box.

### `backend` and `options`

Those two options are used to set the command used to render the TeX files.

`backend` is used to summon a different backend (e.g. LuaTeX, XeTeX, etc.); by
default `pdflatex` is used.

`options` is used to add extra options to the command (e.g. custom formats).
This is usually not necessary, but you never know. This is empty by default.

<br>

**Note:** LaTeX is run with a specific set of options that are **absolutely 
crucial** for the plug-in to work seamlessly, and are thus **not part** of
`options`. Those options are:
 * `-halt-on-error`: to make LaTeX exit whenever it encounters an error (by
   default it will go in interactive mode and suspend execution, which we do not
   want)
 * `-interaction nonstopmode`: avoid interactive mode (e.g. LaTeX asking you
   some questions or other) as again it would suspend execution in the middle of
   Jekyll running, which would be bad
 * `--jobname=output`: this is to force the output name to be `output`; this is
   used throughout the algorithm so changing it will necessarily break stuff

**I have _not_ tested this plug-in with any other backend than PDFLaTeX.**

If I had to guess I would say this will work fine with XeTeX, but maybe not with
LuaTeX (which decided on a different option format). If you want to use LuaTeX,
either modify the plug-in or ask me, I'll see what I can do.


### `packages` and `extra_packages`

These options are used to add your own packages to the TeX file header, should
you require special command, symbols, etc.

`packages` is set to a minimal list by default, consisting of the following
packages:
 * `inputenc` with option `utf8`
 * `fontenc` with option `T1`
 * `amsmath`
 * `amssymb`

The first two packages are recommended for smooth operation and rendering, the
latter ones are to have basic math stuff made available.

Since this is given as a default value, setting `packages` manually will
**override** this list. To **add** to this list, use the `extra_packages` option
instead (empty by default).

Packages are defined by a _name_ and an optional _option_. For instance:
```yaml
...
  extra_packages:
    - name: "abc"
      option: "1,23,v=5"
    - name: "def"
```

When translated into a TeX file, this becomes:
```latex
...
\usepackage[1,23,v=5]{abc}
\usepackage{def}
```

### `extra_head`

This option allows to add custom code in the header of the generate TeX file.
This code is put right after the `\usepackage` part and right before
`\begin{document}`.

This option is mainly intended to be used for incorporating custom commands to
be used in your equation, or possibly to set special options (specific math
fonts for instance).

**Extreme care** should be taken, as this piece of code is appended to the
generated TeX files. If this code is erroneous, it will result in errors at
generation time, and it can be difficult to track them down (one may think the
problem comes from the equation while in fact it comes from the header).

I strongly advise you to test your code before putting it in the options!

Note that this is empty by default.


### `outdir`

This option is used to specify where the generated SVG files should be put. By
default, the path `/assets/texeqn` is provided.

This path should also be part of your `include` option in your config file.


### `tmpdir`

This option is used to specify where intermediate files are to be put. This
include in particular the generated TeX and LaTeX auxiliary files created during
compilation.

By default this path is set to `_tmp`. It should also be part of your `exclude`
option, so that any remnant files (see below) are not accidentally included in
your website.


### `inlineclass` and `blockclass`

These options allow to add a specific set of _CSS classes_ to the generated
piece of HTML code.

Concretely, an equation is turned into an SVG image + HTML code to include this
image in your document. The generated HTML code has the following form:
```html
<span class="...inlineclass..."><img ... /></span>     (inline equations)
<div class="...blockclass..."><img ... /></span>       (block equations)
```

These options allow to specify what is put in the class attribute of the
wrapping `span` or `div` tag. This is especially useful for easy typesetting of
your page (e.g. setting padding for in-line equations, centering block
equations, etc.).

Both options are empty by default.

### `inline_scale` and `block_scale`

These options are used to scale the generated SVG images to the desired size.
Scale is used to have homogeneous sizes throughout your documents, as well as to
preserve the aspect ratio of each image.

The default values given are `2.4` for both options, which seems to work
reasonably well for 12pt websites.


## The Sausage Making

The general pipeline for this plug-in is the following:
 * Liquid stumbles upon the custom tags;
 * Liquid calls the associated classes;
 * The content of the tag is extracted and put in a temporary TeX file, together 
   with the additional packages and header defined in the options; the file is
   placed in the path specified by `tmpdir`, and its name is based *on the
   "host" file plus a hash of the extracted content* (to ensure uniqueness);
 * In-line equations are written between `$...$`, block equations between
   `\begin{displaymath}...\end{displaymath}`;
 * The provided TeX back-end is summoned on the generated TeX file;
 * The generated PDF is cropped using `pdfcrop`;
 * The resulting cropped PDF is turned into an SVG image using `pdf2svg`;
 * The SVG image is placed in the directory specified by `outputdir`;
 * The size of the image is extracted using black magic;
 * A piece of HTML code is generated in place of the Liquid tag/block, that
   references the generated SVG image and sets its size using the extracted
   dimensions and the scale factor provided in the options;
 * The TeX and PDF files as well as LaTeX's generated junk are cleaned up;

Rinse and repeat for each piece of equation. If you have a lot, this will surely
take a bit of time...

Note that initially the plug-in would first generate every TeX file and _then_
compile them, but the generate `img` tag requires the image's dimensions, which
can only be accessed in the generated SVG file.

If at any point the procedure (especially one of the summoned commands!) fail,
an exception is raised, causing Jekyll to report it as an error. In that case
**the generated files are _not_ cleaned**.


## Known Limitations and Possible Quirky Behaviours

I am aware of a few limitations, some of them I may fix in the future, most of
them I won't, by lack of time or interest (sorry). Of course this is an open
source project under MIT license feel to do whatever you want with it; I will
examine pull requests and reported issues!

<br>

1. *The generated SVG files are not included in the generated site (meaning you
need to run build again if you want them to be noticed by Jekyll and copied
in `_site`)*

Honestly I do not know why. My guess is that Jekyll decides on which file will
be included before transforming the files? This is not a *huge* problem but you
need to be aware of it as you need to run build twice :(

I guess I _could_ copy them myself, but it looks like an ugly Chatterton-style
fix and I do not like it.

<br>

2. *In case of error generated files (TeX+side files generated by LaTeX) are not
cleaned up (meaning once in a while you need to empty the ashtray yourself)*

I do not really know to deal with it in a satisfactory way, and in the end I do
not think I should. Among the remnant files are the `.log` which could be useful
if you need to debug your LaTeX code.

<br>

3. *The plug-in is not generating a new image (e.g. keeping the old one or not
processing the TeX file it has generated)*

The plug-in goes through a full generation step if and only if: 1) there does
not exist a TeX file for that equation already, and 2) there does not exist a
SVG file for that equation already.

Why? Well this is a coherent behaviour 99% of the time:
 * If the TeX file exists, this means it has not been cleaned, and thus that
   something went wrong during compilation (typically, LaTeX errors). The
   plug-in will not process it again, as there is virtually no chance the file
   has changed since the last attempt at compiling it (remember the file's name
   is based on a _hash of its content_); the only exception to that is if the
   **provided extra LaTeX header is erroneous**, but that is (or should be)
   quite rare;
 * If the SVG file exists, and for the same reason that the content of the
   equation is very unlikely to have changed, that means there is nothing to do.
   Again, there might be something new in the extra LaTeX header you provided,
   or some options you added to `_config.yml` you would like the plug-in to take
   into account, but this would also be fairly uncommon;

In either way, the solution is just to remove the generated file manually (both
the TeX and the SVG, if it exists). This should be sufficient to force the
plug-in to re-generate the associated equation.

<br>

4. *Generation is done on reading the tags, which is heavy and slow.*

I know, it used to be more of an asynchronous create-task-execute-task kind of
pattern but I needed the size of the SVG file (otherwise I could not scale it
properly).

I think something better could be done, at the price of a complex infrastructure
which I do not want to delve into the making of.

In the meantime the solution works fairly well, especially in its "nominal
setting" (i.e. static, one step build, no serve).

<br>

5. *It would be nice to have support for.../I encountered a bug...*

Right now this project fits my personnal need, nothing more. If you require
particular features, you can always ask politely but I cannot guarantee you I
will do anything about it.

You can also work on features yourself and propose fixes an patches, I will look
into it!

<br>

6. *OMG this is so ugly bleeeeeeeh*

I have not written a single line of Ruby in my whole life T^T, please be 
indulgent and deal with it quietly.





