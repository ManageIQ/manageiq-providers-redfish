describe ManageIQ::Providers::Redfish::PhysicalInfraManager::FirmwareUpdateTask do
  before { EvmSpecHelper.create_guid_miq_server_zone }

  let(:ems)             { FactoryBot.create(:ems_redfish_physical_infra) }
  let(:server)          { FactoryBot.create(:physical_server, :ext_management_system => ems) }
  let(:request)         { FactoryBot.create(:physical_server_firmware_update_request, :options => options) }
  let(:firmware_binary) { FactoryBot.create(:firmware_binary) }

  subject { described_class.new(:source => server, :miq_request => request) }

  describe 'run state machine' do
    before { subject.update(:options => options) }
    before { allow(subject).to receive(:requeue_phase) { subject.send(subject.phase) } }
    before do
      allow(subject).to receive(:signal) do |method|
        subject.phase = method
        subject.send(method)
      end
    end

    context 'abort when missing firmware binary' do
      let(:options) { { :firmware_binary_id => 'missing' } }
      it do
        expect { subject.start_firmware_update }.to raise_error(MiqException::MiqFirmwareUpdateError)
      end
    end

    context 'abort when missing one of servers' do
      let(:options) { { :src_ids => [server.id, 'missing'], :firmware_binary_id => firmware_binary.id } }
      it do
        expect { subject.start_firmware_update }.to raise_error(MiqException::MiqFirmwareUpdateError)
      end
    end

    context 'when all steps succeed' do
      let(:options)  { { :src_ids => [server.id], :firmware_binary_id => firmware_binary.id } }
      let(:response) { double('response', :done? => true) }
      it do
        expect(request).to receive(:affected_ems).and_return(ems)
        expect(ems).to receive(:update_firmware_async).with(firmware_binary, [server]).and_return(response)
        expect(subject).to receive(:done_firmware_update)
        subject.start_firmware_update
      end
    end

    context 'when all steps succeed after polling' do
      before { allow(ems).to receive(:with_provider_connection).and_yield(client) }
      before { allow(client).to receive(:get).and_return(response, response, response_ok) }
      before { allow(request).to receive(:affected_ems).and_return(ems) }
      let(:options)     { { :src_ids => [server.id], :firmware_binary_id => firmware_binary.id } }
      let(:client)      { double('client') }
      let(:response)    { double('response', :done? => false, :monitor => '/monitor', :to_h => {}) }
      let(:response_ok) { double('response-ok', :done? => true) }
      it do
        expect(ems).to receive(:update_firmware_async).with(firmware_binary, [server]).and_return(response)
        expect(subject).to receive(:done_firmware_update)
        subject.start_firmware_update
      end
    end
  end
end
