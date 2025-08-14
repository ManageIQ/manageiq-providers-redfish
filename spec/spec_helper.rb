if ENV['CI']
  require 'simplecov'
  SimpleCov.start
end

Dir[Rails.root.join("spec/shared/**/*.rb")].each { |f| require f }
Dir[File.join(__dir__, "support/**/*.rb")].each { |f| require f }

require "manageiq/providers/redfish"

VCR.configure do |config|
  config.ignore_hosts 'codeclimate.com' if ENV['CI']
  config.cassette_library_dir = File.join(ManageIQ::Providers::Redfish::Engine.root, 'spec/vcr_cassettes')
  config.default_cassette_options = {
    :match_requests_on            => %i(method uri body),
    :update_content_length_header => true
  }
  config.configure_rspec_metadata! # Auto-detects the cassette name based on the example's full description

  VcrSecrets.define_all_cassette_placeholders(config, :redfish)
end
