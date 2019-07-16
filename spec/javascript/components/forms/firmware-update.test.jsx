import FirmwareUpdate from '../../../../app/javascript/components/forms/firmware-update'

let renderComponent;

describe('FirmwareUpdate', () => {
  beforeAll(() => {
    renderComponent = (loading = false, physicalServers = [], firmwareBinaries = []) => shallowRedux(
      <FirmwareUpdate
        updateFormState={jest.fn()} loading={loading}
        physicalServerIds={physicalServers}
        firmwareBinaries={firmwareBinaries}
      />
      );
  });

  describe('renders', () => {
    it('spinner', () => {
      let component = renderComponent(true);
      expect(toJson(component)).toMatchSnapshot();
    });

    describe('form', () => {
      it('with zero physicalServers', () => {
        let component = renderComponent(false);
        expect(toJson(component)).toMatchSnapshot();
      });

      it('with two physicalServers', () => {
        let component = renderComponent(false, ['server1', 'server2']);
        expect(toJson(component)).toMatchSnapshot();
      });

      it('with two physicalServers and one firmware binary', () => {
        let component = renderComponent(false, ['server1', 'server2'], [{value: 'binary1', label: 'BINARY1'}]);
        expect(toJson(component)).toMatchSnapshot();
      });
    });
  });
});
