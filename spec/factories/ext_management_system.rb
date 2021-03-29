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
      hostname { Rails.application.secrets.redfish[:host] }

      after(:create) do |ems|
        secrets = Rails.application.secrets.redfish
        ems.authentications << FactoryBot.create(
          :authentication,
          :userid   => secrets[:userid],
          :password => secrets[:password]
        )
      end
    end
  end
end
