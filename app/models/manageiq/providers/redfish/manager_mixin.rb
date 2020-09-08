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
    def params_for_create
      @params_for_create ||= {
        :fields => [
          {
            :component => 'sub-form',
            :id        => 'endpoints-subform',
            :name      => 'endpoints-subform',
            :title     => _('Endpoints'),
            :fields    => [
              {
                :component              => 'validate-provider-credentials',
                :id                     => 'authentications.default.valid',
                :name                   => 'authentications.default.valid',
                :skipSubmit             => true,
                :validationDependencies => %w[type],
                :fields                 => [
                  {
                    :component  => "select",
                    :id         => "endpoints.default.security_protocol",
                    :name       => "endpoints.default.security_protocol",
                    :label      => _("Security Protocol"),
                    :isRequired => true,
                    :validate   => [{:type => "required"}],
                    :options    => [
                      {
                        :label => _("SSL without validation"),
                        :value => "ssl-no-validation"
                      },
                      {
                        :label => _("SSL"),
                        :value => "ssl-with-validation"
                      },
                      {
                        :label => _("Non-SSL"),
                        :value => "non-ssl"
                      }
                    ]
                  },
                  {
                    :component  => "text-field",
                    :id         => "endpoints.default.hostname",
                    :name       => "endpoints.default.hostname",
                    :label      => _("Hostname (or IPv4 or IPv6 address)"),
                    :isRequired => true,
                    :validate   => [{:type => "required"}],
                  },
                  {
                    :component    => "text-field",
                    :id           => "endpoints.default.port",
                    :name         => "endpoints.default.port",
                    :label        => _("API Port"),
                    :type         => "number",
                    :initialValue => 443,
                    :isRequired   => true,
                    :validate     => [{:type => "required"}],
                  },
                  {
                    :component  => "text-field",
                    :id         => "authentications.default.userid",
                    :name       => "authentications.default.userid",
                    :label      => "Username",
                    :isRequired => true,
                    :validate   => [{:type => "required"}],
                  },
                  {
                    :component  => "password-field",
                    :id         => "authentications.default.password",
                    :name       => "authentications.default.password",
                    :label      => "Password",
                    :type       => "password",
                    :isRequired => true,
                    :validate   => [{:type => "required"}],
                  },
                ]
              },
            ],
          },
        ]
      }.freeze
    end

    # Verify Credentials
    #
    # args: {
    #   "endpoints" => {
    #     "default" => {
    #       "security_protocol" => String,
    #       "hostname" => String,
    #       "port" => Integer,
    #     }
    #   "authentications" => {
    #     "default" => {
    #       "userid" => String,
    #       "password" => String,
    #     }
    #   }

    def verify_credentials(args)
      endpoint = args.dig("endpoints", "default")
      authentication = args.dig("authentications", "default")

      hostname, port, security_protocol = endpoint&.values_at("hostname", "port", "security_protocol")
      userid, password = authentication&.values_at("userid", "password")

      password = MiqPassword.try_decrypt(password)
      password ||= find(args["id"]).authentication_password(endpoint_name) if args["id"]

      !!raw_connect(userid, password, hostname, port, security_protocol)
    end

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
