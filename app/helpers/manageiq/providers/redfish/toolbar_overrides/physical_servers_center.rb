module ManageIQ::Providers::Redfish
  class ToolbarOverrides::PhysicalServersCenter < ::ApplicationHelper::Toolbar::Override
    button_group(
      "physical_server_policy",
      [
        select(
          :physical_server_lifecycle_choice,
          "fa fa-recycle fa-lg",
          t = N_("Lifecycle"),
          t,
          :enabled => true,
          :items   => [
            button(
              :physical_server_provision,
              "pficon pficon-add-circle-o fa-lg",
              t = N_("Provision Selected Redfish Physical Servers"),
              t,
              :klass   => Button::PhysicalServerButton,
              :data    => {
                "function"      => "sendDataWithRx",
                "function-data" => {
                  :controller     => "provider_dialogs",
                  :button         => :physical_server_provision,
                  :modal_title    => N_("Provision Selected Physical Servers"),
                  :component_name => "RedfishServerProvisionDialog",
                },
              },
              :enabled => false,
              :onwhen  => "1+"
            ),
            button(
              :physical_server_firmware_update,
              "pficon pficon-maintenance fa-lg",
              t = N_("Update Firmware of Selected Redfish Physical Servers"),
              t,
              :klass   => Button::PhysicalServerButton,
              :data    => {
                "function"      => "sendDataWithRx",
                "function-data" => {
                  :controller     => "provider_dialogs",
                  :button         => :physical_server_firmware_update,
                  :modal_title    => N_("Update Physical Servers' Firmware"),
                  :component_name => "RedfishServerFirmwareUpdateDialog",
                },
              },
              :enabled => false,
              :onwhen  => "1+"
            ),
          ]
        ),
      ]
    )
  end
end
