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

  config.configure_rspec_metadata!
  config.default_cassette_options = {
    :match_requests_on            => %i(method uri body),
    :update_content_length_header => true
  }

  secrets = Rails.application.secrets
  secrets.redfish.each_key do |secret|
    config.filter_sensitive_data(secrets.redfish_defaults[secret]) { secrets.redfish[secret] }
  end
end
