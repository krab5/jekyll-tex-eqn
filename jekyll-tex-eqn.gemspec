Gem::Specification.new do |s|
  s.name        = "jekyll-tex-eqn"
  s.summary     = "Standalone, static, no-JS, TeX-rendered mathematical equations for your Jekyll website"
  s.version     = "0.9.0"
  s.authors     = ["krab5"]
  s.email       = "crab.delicieux@gmail.com"

  s.homepage = "https://github.com/krab5/jekyll-tex-eqn"
  s.licenses = ["MIT"]
  s.files    = ["lib/jekyll-tex-eqn.rb"]

  s.required_ruby_version = ">= 2.4.0"

  s.add_dependency "jekyll", ">= 3.0", "< 5.0"
  s.add_dependency "digest", "~> 3.0"
  s.add_dependency "fileutils", "~> 1.4"

  s.add_development_dependency "bundler", "~> 1.10"
end


