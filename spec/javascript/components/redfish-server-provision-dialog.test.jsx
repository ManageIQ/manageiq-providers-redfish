import RedfishServerProvisionDialog from '../../../app/javascript/components/redfish-server-provision-dialog'
import * as api from '../../../app/javascript/utils/api';

const fetchPxeServersMock = jest.spyOn(api, 'fetchPxeServers').mockResolvedValue({resources: []});
const dispatchMock = jest.spyOn(DEFAULT_STORE, 'dispatch');

let renderComponent;
let renderComponentFull;

describe('RedfishServerProvisionDialog', () => {
  beforeAll(() => {
    renderComponent = () => shallowRedux(<RedfishServerProvisionDialog />);
    renderComponentFull = () => mountRedux(<RedfishServerProvisionDialog />);
  });

  beforeEach(() => {
    ManageIQ.record.recordId = 123;
  });

  describe('componentDidMount', () => {
    it('fetchPxeServers succeeds', () => {
      fetchPxeServersMock.mockResolvedValue({resources: [{ id: 1, name: 'PXE1', uri: 'URI1' }]});
      let component = renderComponent();
      return fetchPxeServersMock().then(() => {
        component.update();
        expect(fetchPxeServersMock).toHaveBeenCalled();
        expect(component.state().loading).toEqual(false);
        expect(component.state().pxeServers).toEqual([{'label': 'PXE1 (URI1)', 'value': 1}]);
        expect(toJson(component)).toMatchSnapshot();
      });
    });

    it('fetchPxeServers fails', () => {
      fetchPxeServersMock.mockRejectedValue({data: {error: { message: 'MSG'}}});
      let component = renderComponent();
      return fetchPxeServersMock().catch(() => {
        component.update();
        expect(fetchPxeServersMock).toHaveBeenCalled();
        expect(component.state().loading).toEqual(false);
        expect(component.state().error).toEqual('MSG');
        expect(toJson(component)).toMatchSnapshot();
      });
    });
  });

  describe('redux bindings', () => {
    it('when fully mounted', () => {
      fetchPxeServersMock.mockResolvedValue({resources: []});
      let component = renderComponentFull();
      return fetchPxeServersMock().then(() => {
        expect(dispatchMock).toHaveBeenCalledWith({type: 'FormButtons.init',        payload: expect.anything()});
        expect(dispatchMock).toHaveBeenCalledWith({type: 'FormButtons.customLabel', payload: expect.anything()});
        expect(dispatchMock).toHaveBeenCalledWith({type: 'FormButtons.saveable',    payload: expect.anything()});
        expect(dispatchMock).toHaveBeenCalledWith({type: 'FormButtons.pristine',    payload: expect.anything()});
      });
    });
  });
});
