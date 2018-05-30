describe ManageIQ::Providers::Redfish::PhysicalInfraManager::Refresher do
  subject(:ems) do
    FactoryGirl.create(:ems_redfish_physical_infra, :vcr,
                       :security_protocol => "ssl",
                       :port              => 8889)
  end

  let(:server_id) { "/redfish/v1/Systems/System.Embedded.1" }

  describe "refresh", :vcr do
    it "will perform a full refresh" do
      2.times do # Test for refresh idempotence
        EmsRefresh.refresh(ems)
        ems.reload

        assert_ems
        assert_physical_servers
        assert_physical_server_details
      end
    end
  end

  def assert_ems
    expect(ems.physical_servers.count).to eq(1)
    expect(ems.physical_servers.map(&:ems_ref)).to match_array([server_id])
    expect(ems.physical_server_details.count).to eq(1)
  end

  def assert_physical_servers
    s = PhysicalServer.find_by(:ems_ref => server_id)
    expect(s).to have_attributes(
      :type                   => "ManageIQ::Providers::Redfish::PhysicalInfraManager::PhysicalServer",
      :ems_id                 => ems.id,
      :name                   => "System.Embedded.1",
      :health_state           => "OK",
      :power_state            => "Off",
      :hostname               => "",
      :product_name           => "dummy",
      :manufacturer           => "Dell Inc.",
      :machine_type           => "dummy",
      :model                  => "DSS9630M",
      :serial_number          => "CN701636AB0013",
      :field_replaceable_unit => "dummy",
      :raw_power_state        => "Off",
      :vendor                 => "unknown",
      :location_led_state     => "Off",
      :physical_rack_id       => 0
    )
  end

  def assert_physical_server_details
    d = AssetDetail.find_by(:resource_type => "PhysicalServer")
    # TODO(tadeboro): We need better source of data before we can create more
    #                 meaningful test.
    expect(d).to have_attributes(
      :resource_type => "PhysicalServer"
    )
  end
end
