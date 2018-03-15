FactoryGirl.define do
  factory :ems_redfish_physical_infra,
          :aliases => ["manageiq/providers/redfish/physical_infra"],
          :class   => "ManageIQ::Providers::Redfish::PhysicalInfraManager",
          :parent  => :ems_physical_infra do
    trait :auth do
      after(:create) do |ems|
        ems.authentications << FactoryGirl.create(:authentication)
      end
    end
  end
end
