require "redfish_client"

module ManageIQ::Providers::Redfish::ManagerMixin
  extend ActiveSupport::Concern

  def connect(options = {})
    if missing_credentials?(options[:auth_type])
      raise MiqException::MiqHostError, "No credentials defined"
    end

    username = options[:user] || authentication_userid(options[:auth_type])
    password = options[:pass] || authentication_password(options[:auth_type])
    host = options[:host] || hostname
    port = options[:port] || self.port
    protocol = options[:protocol] || security_protocol

    self.class.raw_connect(username, password, host, port, protocol)
  end

  def disconnect(connection)
    connection.logout
  rescue StandardError => error
    $redfish_log.warn("Disconnect failed: #{error}")
  end

  def verify_credentials(auth_type = nil, options = {})
    options[:auth_type] = auth_type
    with_provider_connection(options) { true }
  end

  module ClassMethods
    def raw_connect(username, password, host, port, protocol)
      url = service_url(protocol, host, port)
      verify = (protocol == "ssl-with-validation")

      connection_rescue_block do
        # TODO(tadeboro): Make prefix configurable from UI
        c = RedfishClient.new(url, :prefix => "/redfish/v1", :verify => verify)
        c.login(username, password)
        c
      end
    end

    SCHEME_LUT = {
      "ssl"                 => "https",
      "ssl-with-validation" => "https",
      "non-ssl"             => "http"
    }.freeze

    def service_url(protocol, host, port)
      scheme = SCHEME_LUT[protocol]
      URI::Generic.build(:scheme => scheme, :host => host, :port => port).to_s
    end

    def translate_exception(err)
      MiqException::MiqEVMLoginError.new(
        "Unexpected response returned from system: #{err.message}"
      )
    end

    def connection_rescue_block
      yield
    rescue StandardError => err
      miq_exception = translate_exception(err)
      raise miq_exception
    end
  end
end
