# -*- encoding: utf-8 -*-
# stub: tilt-jbuilder 0.7.1 ruby lib

Gem::Specification.new do |s|
  s.name = "tilt-jbuilder".freeze
  s.version = "0.7.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Anthony Smith".freeze]
  s.date = "2016-01-30"
  s.description = "Jbuilder support for Tilt".freeze
  s.email = ["anthony@sticksnleaves.com".freeze]
  s.homepage = "https://github.com/anthonator/tilt-jbuilder".freeze
  s.rubygems_version = "3.0.3".freeze
  s.summary = "Adds support for rendering Jbuilder templates in Tilt.".freeze

  s.installed_by_version = "3.0.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<tilt>.freeze, [">= 1.3.0", "< 3"])
      s.add_runtime_dependency(%q<jbuilder>.freeze, [">= 0"])
      s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
    else
      s.add_dependency(%q<tilt>.freeze, [">= 1.3.0", "< 3"])
      s.add_dependency(%q<jbuilder>.freeze, [">= 0"])
      s.add_dependency(%q<bundler>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<tilt>.freeze, [">= 1.3.0", "< 3"])
    s.add_dependency(%q<jbuilder>.freeze, [">= 0"])
    s.add_dependency(%q<bundler>.freeze, [">= 0"])
  end
end
