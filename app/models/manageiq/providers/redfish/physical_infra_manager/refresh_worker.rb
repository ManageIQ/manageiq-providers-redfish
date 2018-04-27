module ManageIQ::Providers::Redfish
  class PhysicalInfraManager::RefreshWorker < ::MiqEmsRefreshWorker
    require_nested :Runner

    def self.ems_class
      ManageIQ::Providers::Redfish::PhysicalInfraManager
    end

    def self.settings_name
      :ems_refresh_worker_redfish_physical_infra
    end
  end
end
