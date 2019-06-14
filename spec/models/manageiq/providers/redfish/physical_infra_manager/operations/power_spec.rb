describe ManageIQ::Providers::Redfish::PhysicalInfraManager do
  subject(:ems) do
    FactoryBot.create(:ems_redfish_physical_infra, :vcr)
  end
  let(:server) do
    FactoryBot.create(:redfish_physical_server, :vcr,
                      :ext_management_system => ems)
  end

  describe "#power_on", :vcr do
    it "powers on the system" do
      expect { ems.power_on(server, nil) }.to raise_error(MiqException::Error)
    end
  end

  describe "#power_off", :vcr do
    it "powers off the system" do
      expect(ems.power_off(server, nil).status).to eq(200)
    end
  end

  describe "#power_off_now", :vcr do
    it "powers off the system immediately" do
      expect(ems.power_off_now(server, nil).status).to eq(200)
    end
  end

  describe "#restart", :vcr do
    it "restarts the system" do
      expect(ems.restart(server, nil).status).to eq(200)
    end
  end

  describe "#restart_now", :vcr do
    it "restarts the system immediately" do
      expect(ems.restart_now(server, nil).status).to eq(200)
    end
  end

  describe "#restart_to_sys_setup", :vcr do
    it "restarts to system setup" do
      expect { ems.restart_to_sys_setup(server, nil) }
        .to raise_error(MiqException::Error)
    end
  end

  describe "#restart_mgmt_controller", :vcr do
    it "restarts management controller" do
      expect { ems.restart_mgmt_controller(server, nil) }
        .to raise_error(MiqException::Error)
    end
  end
end
