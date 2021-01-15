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

        def self.init_loggers
          $redfish_log ||= Vmdb::Loggers.create_logger("redfish.log")
        end

        def self.apply_logger_config(config)
          Vmdb::Loggers.apply_config_value(config, $redfish_log, :level_redfish)
        end
      end
    end
  end
end
