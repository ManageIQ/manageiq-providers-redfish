class ManageIQ::Providers::Redfish::PhysicalInfraManager::Provision < ::PhysicalServerProvisionTask
  include_concern 'StateMachine'
end
