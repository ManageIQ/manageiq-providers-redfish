module ManageIQ::Providers::Redfish
  class ToolbarOverrides::PhysicalServersCenter \
      < ::ApplicationHelper::Toolbar::Override
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
              t = N_("Provision Selected Physical Servers"),
              t,
              :klass   => ApplicationHelper::Button::ButtonWithoutRbacCheck,
              :data    => {
                "function"      => "sendDataWithRx",
                "function-data" => {
                  :controller     => "provider_dialogs",
                  :button         => :physical_server_provision,
                  :modal_title    => N_("Provision Selected Physical Servers"),
                  :component_name => "RedfishServerProvisionDialog",
                }.to_json,
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
