import React from 'react';
import { screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import fetchMock from 'fetch-mock';
import { renderWithRedux } from '@@spec-helpers/mountForm';

import RedfishServerFirmwareUpdateDialog from '../../components/redfish-server-firmware-update-dialog';

describe('RedfishServerFirmwareUpdateDialog', () => {
  const serverId = '11';
  const binariesUrl = `/api/physical_servers/${serverId}/firmware_binaries?expand=resources&attributes=id,name,description`;
  const binariesResponse = {
    resources: [
      { id: '1', name: 'bios', description: 'BIOS 1.0' },
      { id: '2', name: 'bmc', description: 'BMC 2.0' },
    ],
  };

  let dispatchSpy;
  let addFlashSpy;

  const renderDialog = () => renderWithRedux(<RedfishServerFirmwareUpdateDialog />);

  const submitForm = async() => {
    const call = dispatchSpy.mock.calls.find(([action]) => action.type === 'FormButtons.callbacks');
    await waitFor(() => { call[0].payload.addClicked(); });
  };

  beforeAll(() => {
    fetchMock.mockGlobal();
  });

  beforeEach(() => {
    ManageIQ.gridChecks = [serverId, '12'];
    dispatchSpy = jest.spyOn(ManageIQ.redux.store, 'dispatch');
    addFlashSpy = jest.spyOn(window, 'add_flash').mockImplementation(() => true);
  });

  afterEach(() => {
    ManageIQ.gridChecks = [];
    dispatchSpy.mockRestore();
    addFlashSpy.mockRestore();
    fetchMock.removeRoutes();
    fetchMock.callHistory.clear();
  });

  const selectBinary = async(user, name) => {
    await user.click(await screen.findByRole('combobox'));
    await user.click(await screen.findByRole('option', { name }));
  };

  it('loads the firmware binaries of the first selected server', async() => {
    fetchMock.get(binariesUrl, binariesResponse);
    renderDialog();

    await waitFor(() => expect(fetchMock.callHistory.called(binariesUrl)).toBe(true));
    expect(fetchMock.callHistory.calls()).toHaveLength(1);
  });

  it('renders the firmware binary options', async() => {
    const user = userEvent.setup();
    fetchMock.get(binariesUrl, binariesResponse);
    renderDialog();

    expect(await screen.findByText('Firmware Binary')).toBeInTheDocument();
    await user.click(await screen.findByRole('combobox'));
    expect(await screen.findByRole('option', { name: 'bios (BIOS 1.0)' })).toBeInTheDocument();
    expect(screen.getByRole('option', { name: 'bmc (BMC 2.0)' })).toBeInTheDocument();
  });

  it('initializes the form buttons', async() => {
    fetchMock.get(binariesUrl, binariesResponse);
    renderDialog();

    await waitFor(() => {
      expect(dispatchSpy).toHaveBeenCalledWith({
        type: 'FormButtons.init',
        payload: { newRecord: true, pristine: true },
      });
      expect(dispatchSpy).toHaveBeenCalledWith({
        type: 'FormButtons.customLabel',
        payload: 'Apply Firmware',
      });
      expect(dispatchSpy).toHaveBeenCalledWith({
        type: 'FormButtons.callbacks',
        payload: { addClicked: expect.any(Function) },
      });
    });
  });

  it('posts a firmware update request and flashes the results', async() => {
    const user = userEvent.setup();
    const postUrl = '/api/requests';
    fetchMock.get(binariesUrl, binariesResponse);
    fetchMock.postOnce(postUrl, {
      results: [
        { message: 'Updated', status: 'Ok' },
        { message: 'Failed', status: 'Error' },
      ],
    });
    renderDialog();

    await selectBinary(user, 'bmc (BMC 2.0)');
    await submitForm();

    await waitFor(() => expect(fetchMock.callHistory.called(postUrl, { method: 'POST' })).toBe(true));
    const body = JSON.parse(fetchMock.callHistory.lastCall(postUrl).options.body);
    expect(body).toEqual({
      options: {
        request_type: 'physical_server_firmware_update',
        src_ids: [serverId, '12'],
        firmware_binary_id: '2',
      },
      auto_approve: true,
    });

    await waitFor(() => {
      expect(addFlashSpy).toHaveBeenCalledWith('Updated', 'success');
      expect(addFlashSpy).toHaveBeenCalledWith('Failed', 'error');
    });
  });

  it('does not post a request when no firmware binary is selected', async() => {
    fetchMock.get(binariesUrl, binariesResponse);
    renderDialog();

    await screen.findByRole('combobox');
    await submitForm();

    await waitFor(() => expect(fetchMock.callHistory.called('/api/requests')).toBe(false));
    expect(addFlashSpy).not.toHaveBeenCalled();
  });

  it('uses the current record when no grid items are checked', async() => {
    ManageIQ.gridChecks = [];
    ManageIQ.record = { recordId: '99' };
    const url = '/api/physical_servers/99/firmware_binaries?expand=resources&attributes=id,name,description';
    fetchMock.get(url, binariesResponse);
    renderDialog();

    await waitFor(() => expect(fetchMock.callHistory.called(url)).toBe(true));
    ManageIQ.record = {};
  });
});
