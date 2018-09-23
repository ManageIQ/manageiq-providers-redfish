module ManageIQ::Providers::Redfish
  class PhysicalInfraManager::EventCatcher \
      < ManageIQ::Providers::BaseManager::EventCatcher
    require_nested :Runner
  end
end
