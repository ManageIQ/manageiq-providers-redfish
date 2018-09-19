module ManageIQ::Providers::Redfish
  class PhysicalInfraManager::PhysicalRack < ::PhysicalRack
    def self.display_name(number = 1)
      n_('Physical Rack (Redfish)', 'Physical Rack (Redfish)', number)
    end
  end
end
