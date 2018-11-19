$:.push File.expand_path("../lib", __FILE__)

require "manageiq/providers/redfish/version"

Gem::Specification.new do |s|
  s.name        = "manageiq-providers-redfish"
  s.version     = ManageIQ::Providers::Redfish::VERSION
  s.authors     = ["ManageIQ Developers"]
  s.homepage    = "https://github.com/ManageIQ/manageiq-providers-redfish"
  s.summary     = "Redfish Provider for ManageIQ"
  s.description = "Redfish Provider for ManageIQ"
  s.licenses    = ["Apache-2.0"]

  s.files = Dir["{app,config,lib}/**/*"]

  s.add_runtime_dependency "redfish_client", "~> 0.4.0"

  s.add_development_dependency "codeclimate-test-reporter", "~> 1.0.0"
  s.add_development_dependency "redfish_tools", "~> 0.1"
  s.add_development_dependency "simplecov"
end
