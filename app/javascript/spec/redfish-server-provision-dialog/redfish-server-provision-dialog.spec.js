import React from 'react';
import { screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import fetchMock from 'fetch-mock';
import { renderWithRedux } from '@@spec-helpers/mountForm';

import RedfishServerProvisionDialog from '../../components/redfish-server-provision-dialog';

describe('RedfishServerProvisionDialog', () => {
  const pxeServersUrl = '/api/pxe_servers?expand=resources&attributes=id,name,uri';
  const pxeImagesUrl = '/api/pxe_servers/1/pxe_images?expand=resources&attributes=id,name,pxe_image_type_id';
  const templatesUrl = '/api/pxe_images/10/customization_templates?expand=resources&attributes=id,name';
  const postUrl = '/api/requests';

  let dispatchSpy;
  let addFlashSpy;

  const renderDialog = () => renderWithRedux(<RedfishServerProvisionDialog />);

  const submitForm = async() => {
    const call = dispatchSpy.mock.calls.find(([action]) => action.type === 'FormButtons.callbacks');
    await waitFor(() => { call[0].payload.addClicked(); });
  };

  const selectOption = async(user, label, optionName) => {
    await user.selectOptions(await screen.findByRole('combobox', { name: label }), optionName);
  };

  beforeAll(() => {
    fetchMock.mockGlobal();
  });

  beforeEach(() => {
    ManageIQ.gridChecks = ['21', '22'];
    dispatchSpy = jest.spyOn(ManageIQ.redux.store, 'dispatch');
    addFlashSpy = jest.spyOn(window, 'add_flash').mockImplementation(() => true);
    fetchMock.get(pxeServersUrl, { resources: [{ id: '1', name: 'pxe1', uri: 'tftp://pxe1' }] });
    fetchMock.get(pxeImagesUrl, { resources: [{ id: '10', name: 'image10' }] });
    fetchMock.get(templatesUrl, { resources: [{ id: '100', name: 'template100' }] });
  });

  afterEach(() => {
    ManageIQ.gridChecks = [];
    dispatchSpy.mockRestore();
    addFlashSpy.mockRestore();
    fetchMock.removeRoutes();
    fetchMock.callHistory.clear();
  });

  it('loads the PXE servers and renders only the PXE server field initially', async() => {
    renderDialog();

    expect(await screen.findByText('PXE Server')).toBeInTheDocument();
    expect(fetchMock.callHistory.called(pxeServersUrl)).toBe(true);
    expect(screen.queryByText('PXE Image')).not.toBeInTheDocument();
    expect(screen.queryByText('Customization Template')).not.toBeInTheDocument();
    expect(fetchMock.callHistory.called(pxeImagesUrl)).toBe(false);
  });

  it('initializes the form buttons', async() => {
    renderDialog();

    await waitFor(() => {
      expect(dispatchSpy).toHaveBeenCalledWith({
        type: 'FormButtons.init',
        payload: { newRecord: true, pristine: true },
      });
      expect(dispatchSpy).toHaveBeenCalledWith({
        type: 'FormButtons.customLabel',
        payload: 'Provision',
      });
      expect(dispatchSpy).toHaveBeenCalledWith({
        type: 'FormButtons.callbacks',
        payload: { addClicked: expect.any(Function) },
      });
    });
  });

  it('loads PXE images after a PXE server is selected, then templates after an image is selected', async() => {
    const user = userEvent.setup();
    renderDialog();

    await selectOption(user, 'PXE Server', 'pxe1 (tftp://pxe1)');
    await waitFor(() => expect(fetchMock.callHistory.called(pxeImagesUrl)).toBe(true));
    expect(screen.queryByText('Customization Template')).not.toBeInTheDocument();

    await selectOption(user, 'PXE Image', 'image10');
    await waitFor(() => expect(fetchMock.callHistory.called(templatesUrl)).toBe(true));
    expect(await screen.findByText('Customization Template')).toBeInTheDocument();
  });

  it('posts a provision request without auto approval and flashes the results', async() => {
    const user = userEvent.setup();
    fetchMock.postOnce(postUrl, {
      results: [
        { message: 'Provisioned', status: 'Ok' },
        { message: 'Failed', status: 'Error' },
      ],
    });
    renderDialog();

    await selectOption(user, 'PXE Server', 'pxe1 (tftp://pxe1)');
    await selectOption(user, 'PXE Image', 'image10');
    await selectOption(user, 'Customization Template', 'template100');
    await submitForm();

    await waitFor(() => expect(fetchMock.callHistory.called(postUrl, { method: 'POST' })).toBe(true));
    const body = JSON.parse(fetchMock.callHistory.lastCall(postUrl).options.body);
    expect(body).toEqual({
      options: {
        request_type: 'provision_physical_server',
        src_ids: ['21', '22'],
        pxe_image_id: '10',
        customization_template_id: '100',
      },
      auto_approve: false,
    });

    await waitFor(() => {
      expect(addFlashSpy).toHaveBeenCalledWith('Provisioned', 'success');
      expect(addFlashSpy).toHaveBeenCalledWith('Failed', 'error');
    });
  });
});
