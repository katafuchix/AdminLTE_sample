# -*- encoding: utf-8 -*-
# stub: swagger-ui_rails 0.1.7 ruby lib

Gem::Specification.new do |s|
  s.name = "swagger-ui_rails".freeze
  s.version = "0.1.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Stjepan Hadjic".freeze]
  s.date = "2014-02-08"
  s.description = "A gem to add swagger-ui to rails asset pipeline".freeze
  s.email = ["Stjepan.hadjic@infinum.hr".freeze]
  s.homepage = "https://github.com/d4be4st/swagger-ui_rails".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.3".freeze
  s.summary = "Add swagger-ui to your rails app easily".freeze

  s.installed_by_version = "3.0.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.3"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    else
      s.add_dependency(%q<bundler>.freeze, ["~> 1.3"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<bundler>.freeze, ["~> 1.3"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
  end
end
