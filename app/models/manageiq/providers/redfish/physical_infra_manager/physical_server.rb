module ManageIQ::Providers::Redfish
  class PhysicalInfraManager::PhysicalServer < ::PhysicalServer
    include_concern 'Provisioning'

    def self.display_name(number = 1)
      n_('Physical Server (Redfish)', 'Physical Servers (Redfish)', number)
    end

    def provider_object(connection)
      connection.find!(ems_ref)
    end
  end
end
