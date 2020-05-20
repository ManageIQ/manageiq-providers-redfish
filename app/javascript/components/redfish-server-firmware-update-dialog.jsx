import React, { useEffect, useMemo } from "react";
import PropTypes from "prop-types";
import { connect } from "react-redux";
import MiqFormRenderer from '@@ddf';

import createSchema from './firmware-update.schema';
import { selectedPhysicalServers } from "../utils/common";

const fetchFirmwareBinaries = (serverId) =>
  API.get(`/api/physical_servers/${serverId}/firmware_binaries?expand=resources&attributes=id,name,description`).then(({ resources }) =>
    resources.map(({ id, name, description }) => ({ value: id, label: `${name} (${description})`}))
  );

const RedfishServerFirmwareUpdateDialog = ({ dispatch }) => {
  const physicalServerIds = selectedPhysicalServers();
  const fetchPromise = useMemo(() => fetchFirmwareBinaries(physicalServerIds[0]), [physicalServerIds]);

  useEffect(() => {
    dispatch({
      type: "FormButtons.init",
      payload: {
        newRecord: true,
        pristine: true,
      }
    });

    dispatch({
      type: "FormButtons.customLabel",
      payload: __('Apply Firmware'),
    });
  }, []);

  const submitValues = ({ firmwareBinaryId }) => {
    API.post(`/api/requests`, {
      options: {
        request_type: 'physical_server_firmware_update',
        src_ids: physicalServerIds,
        firmware_binary_id: firmwareBinaryId
      },
      auto_approve: true
    }).then(response => {
      response['results'].forEach(res => window.add_flash(res.message, res.status === 'Ok' ? 'success' : 'error'));
    });
  };

  const handleFormStateUpdate = (formState) => {
    dispatch({
      type: "FormButtons.saveable",
      payload: formState.valid
    });
    dispatch({
      type: "FormButtons.pristine",
      payload: formState.pristine
    });
    dispatch({
      type: 'FormButtons.callbacks',
      payload: { addClicked: () => submitValues(formState.values) },
    });
  };

  return (
    <MiqFormRenderer
      schema={createSchema(fetchPromise)}
      onSubmit={submitValues}
      showFormControls={false}
      onStateUpdate={handleFormStateUpdate}
    />
  );
};

RedfishServerFirmwareUpdateDialog.propTypes = {
  dispatch: PropTypes.func.isRequired,
};

export default connect()(RedfishServerFirmwareUpdateDialog);
