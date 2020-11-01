# -*- encoding: utf-8 -*-
# stub: piet 0.2.6 ruby lib

Gem::Specification.new do |s|
  s.name = "piet".freeze
  s.version = "0.2.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Albert Bellonch".freeze]
  s.date = "2017-11-29"
  s.description = "-".freeze
  s.email = ["albert@itnig.net".freeze]
  s.homepage = "http://itnig.net".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.3".freeze
  s.summary = "An image optimizer".freeze

  s.installed_by_version = "3.0.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<png_quantizator>.freeze, [">= 0"])
      s.add_development_dependency(%q<rspec>.freeze, [">= 0"])
      s.add_development_dependency(%q<ZenTest>.freeze, [">= 0"])
      s.add_development_dependency(%q<carrierwave>.freeze, [">= 0"])
      s.add_development_dependency(%q<mini_magick>.freeze, [">= 0"])
      s.add_development_dependency(%q<rmagick>.freeze, [">= 0"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    else
      s.add_dependency(%q<png_quantizator>.freeze, [">= 0"])
      s.add_dependency(%q<rspec>.freeze, [">= 0"])
      s.add_dependency(%q<ZenTest>.freeze, [">= 0"])
      s.add_dependency(%q<carrierwave>.freeze, [">= 0"])
      s.add_dependency(%q<mini_magick>.freeze, [">= 0"])
      s.add_dependency(%q<rmagick>.freeze, [">= 0"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<png_quantizator>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, [">= 0"])
    s.add_dependency(%q<ZenTest>.freeze, [">= 0"])
    s.add_dependency(%q<carrierwave>.freeze, [">= 0"])
    s.add_dependency(%q<mini_magick>.freeze, [">= 0"])
    s.add_dependency(%q<rmagick>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
  end
end
