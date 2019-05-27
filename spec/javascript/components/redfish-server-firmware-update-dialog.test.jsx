import RedfishServerFirmwareUpdateDialog from '../../../app/javascript/components/redfish-server-firmware-update-dialog'
import * as api from '../../../app/javascript/utils/api';
import { act } from 'react-dom/test-utils';

const fetchBinariesMock = jest.spyOn(api, 'fetchFirmwareBinariesForServer').mockResolvedValue({resources: []});
const dispatchMock = jest.spyOn(DEFAULT_STORE, 'dispatch');

let renderComponent;
let renderComponentFull;

describe('RedfishServerFirmwareUpdateDialog', () => {
  beforeAll(() => {
    renderComponent = () => shallowRedux(<RedfishServerFirmwareUpdateDialog />);
    renderComponentFull = () => mountRedux(<RedfishServerFirmwareUpdateDialog />);
  });

  beforeEach(() => {
    ManageIQ.record.recordId = 123;
  });

  describe('componentInitHook', () => {
    it('fetchBinaries succeeds', () => {
      fetchBinariesMock.mockResolvedValue({resources: [{ id: 1, name: 'BINARY1', description: 'DESCR1' }]});

      // TODO(miha-plesko): use shallow render here to avoid 'FirmwareUpdate' component rendering.
      // But enzyme guys have to fix a bug first that hooks are not triggered with shallow render, see
      // https://github.com/airbnb/enzyme/issues/2086
      let component = renderComponentFull();
      return fetchBinariesMock().then(() => {
        component.update();
        expect(fetchBinariesMock).toHaveBeenCalled();
        expect(toJson(component)).toMatchSnapshot();
      });
    });

    it('fetchBinaries fails', () => {
      fetchBinariesMock.mockRejectedValue({data: {error: { message: 'MSG'}}});
      // TODO(miha-plesko): use shallow render here to avoid 'FirmwareUpdate' component rendering.
      let component = renderComponentFull();
      return fetchBinariesMock().catch(() => {
        act(() => component.update());
        expect(fetchBinariesMock).toHaveBeenCalled();
        expect(toJson(component)).toMatchSnapshot();
      });
    });
  });

  describe('redux bindings', () => {
    it('when fully mounted', () => {
      fetchBinariesMock.mockResolvedValue({resources: []});
      let component = renderComponentFull();
      return fetchBinariesMock().then(() => {
        expect(dispatchMock).toHaveBeenCalledWith({type: 'FormButtons.init',        payload: expect.anything()});
        expect(dispatchMock).toHaveBeenCalledWith({type: 'FormButtons.customLabel', payload: expect.anything()});
        expect(dispatchMock).toHaveBeenCalledWith({type: 'FormButtons.saveable',    payload: expect.anything()});
        expect(dispatchMock).toHaveBeenCalledWith({type: 'FormButtons.pristine',    payload: expect.anything()});
      });
    });
  });
});
