module ManageIQ::Providers::Redfish
  class PhysicalInfraManager::PhysicalServer < ::PhysicalServer
    def self.display_name(number = 1)
      n_('Physical Server (Redfish)', 'Physical Servers (Redfish)', number)
    end
  end
end
