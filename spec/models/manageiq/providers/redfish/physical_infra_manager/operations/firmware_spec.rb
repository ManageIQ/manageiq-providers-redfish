describe ManageIQ::Providers::Redfish::PhysicalInfraManager do
  before { EvmSpecHelper.create_guid_miq_server_zone }
  before { allow(server1).to receive(:firmware_compatible?).with(firmware_binary).and_return(true) }
  before { allow(server2).to receive(:firmware_compatible?).with(firmware_binary).and_return(true) }
  before { allow(subject).to receive(:with_provider_connection).and_yield(client) }

  let(:ems)             { FactoryBot.create(:ems_physical_infra) }
  let(:server1)         { FactoryBot.create(:physical_server, :ext_management_system => ems) }
  let(:server2)         { FactoryBot.create(:physical_server, :ext_management_system => ems) }
  let(:servers)         { [server1, server2] }
  let(:request)         { FactoryBot.create(:physical_server_firmware_update_request) }
  let(:firmware_binary) { FactoryBot.create(:firmware_binary) }
  let(:client)          { double('client', :UpdateService => update_service) }
  let(:response)        { double('response', :status => 200) }
  let(:actions)         { { '#UpdateService.SimpleUpdate' => update_action } }
  let(:update_service)  { double('update_service', :Actions => actions) }
  let(:update_action) do
    double('update action', :target => 'update-service-url').tap do |d|
      allow(d).to receive(:post).and_return(response)
      allow(d).to receive(:[]).with('TransferProtocol@Redfish.AllowableValues').and_return(['HTTP'])
    end
  end

  describe '#update_firmware_async' do
    before { allow(subject).to receive(:compatible_firmware_url).and_return(%w[HTTP http://url]) }

    context 'when firmware update succeeds' do
      it 'no error is raised' do
        expect { subject.update_firmware_async(firmware_binary, servers) }.not_to raise_error
      end
    end

    context 'when missing server' do
      it 'handled error is raised' do
        expect { subject.update_firmware_async(firmware_binary, []) }.to raise_error(MiqException::MiqFirmwareUpdateError)
      end
    end

    context 'when firmware and server are incompatible' do
      before { allow(server1).to receive(:firmware_compatible?).with(firmware_binary).and_return(false) }
      it 'handled error is raised' do
        expect { subject.update_firmware_async(firmware_binary, servers) }.to raise_error(MiqException::MiqFirmwareUpdateError)
      end
    end

    context 'when update service not available' do
      let(:update_service) { nil }
      it 'handled error is raised' do
        expect { subject.update_firmware_async(firmware_binary, servers) }.to raise_error(MiqException::MiqFirmwareUpdateError)
      end
    end

    context 'when update service returns bad response' do
      let(:response) { double('response', :status => 500, :data => { :body => 'MSG' }) }
      it 'handled error is raised' do
        expect { subject.update_firmware_async(firmware_binary, servers) }.to raise_error(MiqException::MiqFirmwareUpdateError)
      end
    end
  end

  describe '#compatible_firmware_url' do
    before { firmware_binary.endpoints = [binary_http, binary_https] }

    let(:binary_http)  { FactoryBot.create(:endpoint, :url => 'http://test') }
    let(:binary_https) { FactoryBot.create(:endpoint, :url => 'https://test') }

    context 'when protocols are listed in @Redfish.AllowableValues' do
      it 'HTTP endpoint is returned' do
        expect(update_action).to receive(:[]).with('TransferProtocol@Redfish.AllowableValues').and_return(['HTTP'])
        protocol, url = subject.compatible_firmware_url(update_service, firmware_binary)
        expect(protocol).to eq('HTTP')
        expect(url).to eq(binary_http.url)
      end
    end

    context 'when protocols are listed in @Redfish.ActionInfo' do
      let(:params) { [double('param1', :Name => 'TransferProtocol', :AllowableValues => ['HTTP'])] }

      it 'HTTP endpoint is returned' do
        expect(update_action).to receive(:[]).with('TransferProtocol@Redfish.AllowableValues').and_return(nil)
        expect(update_action).to receive(:[]).with('TransferProtocol@Redfish.ActionInfo').and_return(double(:Parameters => params))
        protocol, url = subject.compatible_firmware_url(update_service, firmware_binary)
        expect(protocol).to eq('HTTP')
        expect(url).to eq(binary_http.url)
      end
    end

    context 'when no protocol is listed as supported' do
      it 'managed error is raised' do
        expect(update_action).to receive(:[]).with('TransferProtocol@Redfish.AllowableValues').and_return([])
        expect { subject.compatible_firmware_url(update_service, firmware_binary) }.to raise_error(MiqException::MiqFirmwareUpdateError)
      end
    end

    context 'when no supported protocol has corresponding endpoint' do
      it 'managed error is raised' do
        expect(update_action).to receive(:[]).with('TransferProtocol@Redfish.AllowableValues').and_return(['MISSING'])
        expect { subject.compatible_firmware_url(update_service, firmware_binary) }.to raise_error(MiqException::MiqFirmwareUpdateError)
      end
    end
  end
end
