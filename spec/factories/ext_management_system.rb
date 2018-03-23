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

    trait :vcr do
      hostname do
        # Keep in sync with filter_sensitive_data in spec/spec_helper.rb!
        Rails.application.secrets.redfish.try(:[], "host") || "redfishhost"
      end

      after(:create) do |ems|
        secrets = Rails.application.secrets.redfish
        ems.authentications << FactoryGirl.create(
          :authentication,
          :userid   => secrets.try(:[], "userid") || "REDFISH_USERID",
          :password => secrets.try(:[], "password") || "REDFISH_PASSWORD"
        )
      end
    end
  end
end
