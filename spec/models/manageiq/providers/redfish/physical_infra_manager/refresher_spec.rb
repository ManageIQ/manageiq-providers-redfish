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
        assert_hardwares
      end
    end
  end

  def assert_ems
    expect(ems.physical_servers.count).to eq(1)
    expect(ems.physical_servers.map(&:ems_ref)).to match_array([server_id])
    expect(ems.physical_server_details.count).to eq(1)
    expect(ems.computer_systems.count).to eq(1)
    expect(ems.hardwares.count).to eq(1)
  end

  def assert_physical_servers
    s = PhysicalServer.find_by(:ems_ref => server_id)
    expect(s).to have_attributes(
      :ems_id          => ems.id,
      :health_state    => "OK",
      :hostname        => "",
      :name            => "System.Embedded.1",
      :power_state     => "Off",
      :raw_power_state => "Off",
      :type            => "ManageIQ::Providers::Redfish::PhysicalInfraManager::PhysicalServer",
    )
  end

  def assert_physical_server_details
    d = AssetDetail.find_by(:resource_type => "PhysicalServer")
    expect(d).to have_attributes(
      :location_led_state => "Off",
      :manufacturer       => "Dell Inc.",
      :model              => "DSS9630M",
      :resource_type      => "PhysicalServer",
      :serial_number      => "CN701636AB0013",
    )
  end

  def assert_hardwares
    h = Hardware.first
    expect(h).to have_attributes(
      :disk_capacity   => 0,
      :memory_mb       => 32_768,
      :cpu_total_cores => 40
    )
  end
end
