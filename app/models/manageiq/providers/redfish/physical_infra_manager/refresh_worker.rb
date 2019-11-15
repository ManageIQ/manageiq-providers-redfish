module ManageIQ::Providers::Redfish
  class PhysicalInfraManager::RefreshWorker < ::MiqEmsRefreshWorker
    require_nested :Runner

    def self.settings_name
      :ems_refresh_worker_redfish_physical_infra
    end
  end
end
