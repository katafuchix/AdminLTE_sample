# -*- encoding: utf-8 -*-
# stub: hashie-forbidden_attributes 0.1.1 ruby lib

Gem::Specification.new do |s|
  s.name = "hashie-forbidden_attributes".freeze
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Maxim-Filimonov".freeze, "Daniel Doubrovkine".freeze]
  s.date = "2015-03-23"
  s.description = "Automatic strong parameter detection with Hashie and Forbidden Attributes. Formerly known as hashie_rails".freeze
  s.email = ["tpaktopsp@gmail.com".freeze]
  s.homepage = "https://github.com/Maxim-Filimonov/hashie-forbidden_attributes".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.3".freeze
  s.summary = "Automatic strong parameter detection with Hashie and Forbidden Attributes. Formerly known as hashie_rails".freeze

  s.installed_by_version = "3.0.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<hashie>.freeze, [">= 3.0"])
      s.add_development_dependency(%q<sqlite3>.freeze, [">= 0"])
      s.add_development_dependency(%q<minitest>.freeze, [">= 0"])
      s.add_development_dependency(%q<rails>.freeze, ["~> 4.0"])
      s.add_development_dependency(%q<grape>.freeze, [">= 0"])
    else
      s.add_dependency(%q<hashie>.freeze, [">= 3.0"])
      s.add_dependency(%q<sqlite3>.freeze, [">= 0"])
      s.add_dependency(%q<minitest>.freeze, [">= 0"])
      s.add_dependency(%q<rails>.freeze, ["~> 4.0"])
      s.add_dependency(%q<grape>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<hashie>.freeze, [">= 3.0"])
    s.add_dependency(%q<sqlite3>.freeze, [">= 0"])
    s.add_dependency(%q<minitest>.freeze, [">= 0"])
    s.add_dependency(%q<rails>.freeze, ["~> 4.0"])
    s.add_dependency(%q<grape>.freeze, [">= 0"])
  end
end
