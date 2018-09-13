module ManageIQ::Providers::Redfish
  class PhysicalInfraManager::PhysicalChassis < ::PhysicalChassis
    def self.display_name(number = 1)
      n_('Physical Chassis (Redfish)', 'Physical Chassis (Redfish)', number)
    end
  end
end
