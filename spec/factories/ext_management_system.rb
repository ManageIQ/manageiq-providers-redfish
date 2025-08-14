FactoryBot.define do
  factory :ems_redfish_physical_infra,
          :aliases => ["manageiq/providers/redfish/physical_infra"],
          :class   => "ManageIQ::Providers::Redfish::PhysicalInfraManager",
          :parent  => :ems_physical_infra do
    trait :auth do
      after(:create) do |ems|
        ems.authentications << FactoryBot.create(:authentication)
      end
    end

    trait :vcr do
      security_protocol { "ssl" }
      port { 8889 }
      hostname { VcrSecrets.redfish.host }

      after(:create) do |ems|
        ems.authentications << FactoryBot.create(
          :authentication,
          :userid   => VcrSecrets.redfish.userid,
          :password => VcrSecrets.redfish.password
        )
      end
    end
  end
end
