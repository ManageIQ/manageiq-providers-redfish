module ManageIQ::Providers::Redfish
  class PhysicalInfraManager::Refresher \
      < ManageIQ::Providers::BaseManager::Refresher
    def post_process_refresh_classes
      []
    end
  end
end
