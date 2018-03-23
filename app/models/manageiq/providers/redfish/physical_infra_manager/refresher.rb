module ManageIQ::Providers::Redfish
  class PhysicalInfraManager::Refresher \
      < ManageIQ::Providers::BaseManager::ManagerRefresher
    def post_process_refresh_classes
      []
    end
  end
end
