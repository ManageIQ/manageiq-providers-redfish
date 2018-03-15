describe ManageIQ::Providers::Redfish::PhysicalInfraManager do
  it ".ems_type" do
    expect(described_class.ems_type).to eq("redfish_ph_infra")
  end

  it ".description" do
    expect(described_class.description).to eq("Redfish")
  end

  let(:rf_module) { class_double("RedfishClient").as_stubbed_const }
  let(:rf_client) { instance_double("RedfishClient::Root") }
  subject(:ems) do
    FactoryGirl.create(:ems_redfish_physical_infra, :auth,
                       :hostname => "host",
                       :port     => 1234)
  end

  context ".raw_connect" do
    it "connects over http" do
      expect(rf_module).to receive(:new).with(
        "http://host:1234", :prefix => "/redfish/v1", :verify => false
      ).and_return(rf_client)
      expect(rf_client).to receive(:login).with("user", "pass")
      described_class.raw_connect("user", "pass", "host", 1234, "non-ssl")
    end

    it "connects over https" do
      expect(rf_module).to receive(:new).with(
        "https://host:1234", :prefix => "/redfish/v1", :verify => false
      ).and_return(rf_client)
      expect(rf_client).to receive(:login).with("user", "pass")
      described_class.raw_connect("user", "pass", "host", 1234, "ssl")
    end

    it "connects over verified https" do
      expect(rf_module).to receive(:new).with(
        "https://host:1234", :prefix => "/redfish/v1", :verify => true
      ).and_return(rf_client)
      expect(rf_client).to receive(:login).with("user", "pass")
      described_class.raw_connect("user", "pass", "host", 1234,
                                  "ssl-with-validation")
    end
  end

  context "#connect" do
    it "aborts on missing credentials" do
      ems = FactoryGirl.create(:ems_redfish_physical_infra)
      expect { ems.connect }.to raise_error(MiqException::MiqHostError)
    end

    it "connects over http" do
      expect(rf_module).to receive(:new).with(
        "http://host:1234", :prefix => "/redfish/v1", :verify => false
      ).and_return(rf_client)
      expect(rf_client).to receive(:login).with("testuser", "secret")
      ems.security_protocol = "non-ssl"
      ems.connect
    end

    it "connects over https" do
      expect(rf_module).to receive(:new).with(
        "https://host:1234", :prefix => "/redfish/v1", :verify => false
      ).and_return(rf_client)
      expect(rf_client).to receive(:login).with("testuser", "secret")
      ems.security_protocol = "ssl"
      ems.connect
    end

    it "connects over verified https" do
      expect(rf_module).to receive(:new).with(
        "https://host:1234", :prefix => "/redfish/v1", :verify => true
      ).and_return(rf_client)
      expect(rf_client).to receive(:login).with("testuser", "secret")
      ems.security_protocol = "ssl-with-validation"
      ems.connect
    end
  end

  context "#verify_credentials" do
    it "raises error for unsupported auth type" do
      creds = {
        :unsupported => {
          :userid   => "unsupported",
          :password => "password"
        }
      }
      ems.endpoints << Endpoint.create(:role     => "unsupported",
                                       :hostname => "hostname",
                                       :port     => 1111)
      ems.update_authentication(creds, :save => false)
      expect do
        ems.verify_credentials(:unsupported)
      end.to raise_error(MiqException::MiqEVMLoginError)
    end
  end
end
