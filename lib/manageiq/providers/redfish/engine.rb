module ManageIQ
  module Providers
    module Redfish
      class Engine < ::Rails::Engine
        isolate_namespace ManageIQ::Providers::Redfish

        config.autoload_paths << root.join('lib').to_s

        def self.vmdb_plugin?
          true
        end

        def self.plugin_name
          _('Redfish Provider')
        end
      end
    end
  end
end
