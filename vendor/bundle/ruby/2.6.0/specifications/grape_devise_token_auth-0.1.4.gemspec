# -*- encoding: utf-8 -*-
# stub: grape_devise_token_auth 0.1.4 ruby lib

Gem::Specification.new do |s|
  s.name = "grape_devise_token_auth".freeze
  s.version = "0.1.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Michael Cordell".freeze]
  s.date = "2016-10-11"
  s.email = ["mike@mikecordell.com".freeze]
  s.homepage = "https://github.com/mcordell/grape_devise_token_auth".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.3".freeze
  s.summary = "Allows an existing devise_token_auth/rails project to authenticate a Grape API".freeze

  s.installed_by_version = "3.0.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.8"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_runtime_dependency(%q<grape>.freeze, ["> 0.9.0"])
      s.add_runtime_dependency(%q<devise>.freeze, [">= 3.3"])
      s.add_runtime_dependency(%q<devise_token_auth>.freeze, [">= 0.1.32"])
    else
      s.add_dependency(%q<bundler>.freeze, ["~> 1.8"])
      s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_dependency(%q<grape>.freeze, ["> 0.9.0"])
      s.add_dependency(%q<devise>.freeze, [">= 3.3"])
      s.add_dependency(%q<devise_token_auth>.freeze, [">= 0.1.32"])
    end
  else
    s.add_dependency(%q<bundler>.freeze, ["~> 1.8"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_dependency(%q<grape>.freeze, ["> 0.9.0"])
    s.add_dependency(%q<devise>.freeze, [">= 3.3"])
    s.add_dependency(%q<devise_token_auth>.freeze, [">= 0.1.32"])
  end
end
