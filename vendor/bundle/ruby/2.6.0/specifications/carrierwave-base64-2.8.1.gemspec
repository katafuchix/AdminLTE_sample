# -*- encoding: utf-8 -*-
# stub: carrierwave-base64 2.8.1 ruby lib

Gem::Specification.new do |s|
  s.name = "carrierwave-base64".freeze
  s.version = "2.8.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Yury Lebedev".freeze]
  s.date = "2020-04-15"
  s.description = "This gem can be useful, if you need to upload files to your API from mobile devises.".freeze
  s.email = ["lebedev.yurii@gmail.com".freeze]
  s.homepage = "https://github.com/lebedev-yury/carrierwave-base64".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.3".freeze
  s.summary = "Upload images encoded as base64 to carrierwave.".freeze

  s.installed_by_version = "3.0.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<carrierwave>.freeze, [">= 0.8.0"])
      s.add_runtime_dependency(%q<mime-types>.freeze, ["~> 3.0"])
      s.add_runtime_dependency(%q<mimemagic>.freeze, ["~> 0.3.2"])
      s.add_development_dependency(%q<bundler>.freeze, ["~> 2.1"])
      s.add_development_dependency(%q<carrierwave-mongoid>.freeze, [">= 0"])
      s.add_development_dependency(%q<mongoid>.freeze, [">= 0"])
      s.add_development_dependency(%q<pry>.freeze, [">= 0"])
      s.add_development_dependency(%q<rails>.freeze, ["~> 5"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 12.3.3"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 2.14"])
      s.add_development_dependency(%q<rubocop>.freeze, [">= 0"])
      s.add_development_dependency(%q<sham_rack>.freeze, [">= 0"])
      s.add_development_dependency(%q<sqlite3>.freeze, [">= 0"])
      s.add_development_dependency(%q<yard>.freeze, [">= 0"])
    else
      s.add_dependency(%q<carrierwave>.freeze, [">= 0.8.0"])
      s.add_dependency(%q<mime-types>.freeze, ["~> 3.0"])
      s.add_dependency(%q<mimemagic>.freeze, ["~> 0.3.2"])
      s.add_dependency(%q<bundler>.freeze, ["~> 2.1"])
      s.add_dependency(%q<carrierwave-mongoid>.freeze, [">= 0"])
      s.add_dependency(%q<mongoid>.freeze, [">= 0"])
      s.add_dependency(%q<pry>.freeze, [">= 0"])
      s.add_dependency(%q<rails>.freeze, ["~> 5"])
      s.add_dependency(%q<rake>.freeze, ["~> 12.3.3"])
      s.add_dependency(%q<rspec>.freeze, ["~> 2.14"])
      s.add_dependency(%q<rubocop>.freeze, [">= 0"])
      s.add_dependency(%q<sham_rack>.freeze, [">= 0"])
      s.add_dependency(%q<sqlite3>.freeze, [">= 0"])
      s.add_dependency(%q<yard>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<carrierwave>.freeze, [">= 0.8.0"])
    s.add_dependency(%q<mime-types>.freeze, ["~> 3.0"])
    s.add_dependency(%q<mimemagic>.freeze, ["~> 0.3.2"])
    s.add_dependency(%q<bundler>.freeze, ["~> 2.1"])
    s.add_dependency(%q<carrierwave-mongoid>.freeze, [">= 0"])
    s.add_dependency(%q<mongoid>.freeze, [">= 0"])
    s.add_dependency(%q<pry>.freeze, [">= 0"])
    s.add_dependency(%q<rails>.freeze, ["~> 5"])
    s.add_dependency(%q<rake>.freeze, ["~> 12.3.3"])
    s.add_dependency(%q<rspec>.freeze, ["~> 2.14"])
    s.add_dependency(%q<rubocop>.freeze, [">= 0"])
    s.add_dependency(%q<sham_rack>.freeze, [">= 0"])
    s.add_dependency(%q<sqlite3>.freeze, [">= 0"])
    s.add_dependency(%q<yard>.freeze, [">= 0"])
  end
end
