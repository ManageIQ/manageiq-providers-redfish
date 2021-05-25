module ManageIQ::Providers::Redfish
  class Button::PhysicalServerButton < ::ApplicationHelper::Button::ButtonWithoutRbacCheck
    def visible?
      ::ManageIQ::Providers::Redfish::PhysicalInfraManager::PhysicalServer.any?
    end
  end
end
