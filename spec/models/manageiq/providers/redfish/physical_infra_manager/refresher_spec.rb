describe ManageIQ::Providers::Redfish::PhysicalInfraManager::Refresher do
  subject(:ems) do
    FactoryGirl.create(:ems_redfish_physical_infra, :vcr,
                       :security_protocol => "ssl",
                       :port              => 8889)
  end

  let(:servers) do
    {
      "/redfish/v1/Systems/System-1-1-1-1" => {
        :server       => {
          :health_state    => "OK",
          :name            => "System-1-1-1-1",
          :power_state     => "PoweringOn",
          :raw_power_state => "PoweringOn",
        },
        :asset_detail => {
          :description        => "G5 Computer System Node",
          :location           => "123, Adams Ave., Chesapeake, VA",
          :location_led_state => "Off",
          :manufacturer       => "Dell",
          :model              => "DSS9630M",
          :rack_name          => "Rack-1",
          :serial_number      => "CN701636AB0013",
        },
        :hardware     => {
          :cpu_total_cores => 24,
          :disk_capacity   => 6_017_150_230_528,
          :memory_mb       => 32_768,
        },
      },
      "/redfish/v1/Systems/System-1-1-1-2" => nil,
      "/redfish/v1/Systems/System-1-2-1-1" => {
        :server       => {
          :health_state    => "Critical",
          :hostname        => "hostname.example.com",
          :name            => "System-1-2-1-1",
          :power_state     => "On",
          :raw_power_state => "On",
        },
        :asset_detail => {
          :location           => "123, Adams Ave., Chesapeake, VA",
          :location_led_state => "Blinking",
          :manufacturer       => "Dell Inc.",
          :model              => "DSS9630M",
          :rack_name          => "Rack-1",
          :serial_number      => "945hjf0927mf",
        },
        :hardware     => {
          :cpu_total_cores => 20,
          :disk_capacity   => 412_316_860_416,
          :memory_mb       => 32_768,
        },
      },
    }
  end

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
    expect(ems.physical_servers.count).to eq(3)
    expect(ems.physical_servers.map(&:ems_ref)).to match_array(servers.keys)
    expect(ems.physical_server_details.count).to eq(3)
    expect(ems.computer_systems.count).to eq(3)
    expect(ems.hardwares.count).to eq(3)
  end

  def check_attributes(instance, attrs, key = nil)
    return if attrs.nil?
    expect(instance).to have_attributes(key.nil? ? attrs : attrs[key])
  end

  def assert_physical_servers
    servers.each do |ems_ref, attrs|
      server = PhysicalServer.find_by!(:ems_ref => ems_ref)
      check_attributes(server, attrs, :server)
    end
  end

  def assert_physical_server_details
    servers.each do |server_ems_ref, attrs|
      server = PhysicalServer.find_by!(:ems_ref => server_ems_ref)
      asset_detail = AssetDetail.find_by!(:resource => server)
      check_attributes(asset_detail, attrs, :asset_detail)
    end
  end

  def assert_hardwares
    servers.each do |server_ems_ref, attrs|
      server = PhysicalServer.find_by!(:ems_ref => server_ems_ref)
      system = ComputerSystem.find_by!(:managed_entity => server)
      hardware = Hardware.find_by!(:computer_system => system)
      check_attributes(hardware, attrs, :hardware)
    end
  end
end
