FactoryBot.define do
  factory :redfish_physical_server,
          :class  => "ManageIQ::Providers::Redfish::PhysicalInfraManager::PhysicalServer",
          :parent => :physical_server do
    trait :vcr do
      ems_ref "/redfish/v1/Systems/System.Embedded.1"
    end
  end
end
