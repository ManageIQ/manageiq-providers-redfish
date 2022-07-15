import React, { useState } from "react";
import PropTypes from "prop-types";
import { connect } from "react-redux";
import MiqFormRenderer from '@@ddf';

import createSchema from './firmware-update.schema';
import { selectedPhysicalServers } from "../utils/common";

const RedfishServerFirmwareUpdateDialog = ({ dispatch }) => {
  const physicalServerIds = selectedPhysicalServers();
  const [{ firmwareBinaryOptions }, setState] = useState();
  
  API.get(`/api/physical_servers/${physicalServerIds[0]}/firmware_binaries?expand=resources&attributes=id,name,description`).then(({ resources }) => {
    const firmwareBinaries = [];
    resources.forEach((firmwareBinary) => {
      firmwareBinaries.push({
        value: firmwareBinary.id,
        label: `${firmwareBinary.name} (${firmwareBinary.description})`
      })
    });
    setState({
      firmwareBinaryOptions: firmwareBinaries,
    });
  }
);

  const initialize = (formOptions) => {
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

    dispatch({
      type: 'FormButtons.callbacks',
      payload: { addClicked: () => formOptions.submit() },
    });
  };

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

  return (
    <MiqFormRenderer
      schema={createSchema(firmwareBinaryOptions)}
      onSubmit={submitValues}
      showFormControls={false}
      initialize={initialize}
    />
  );
};

RedfishServerFirmwareUpdateDialog.propTypes = {
  dispatch: PropTypes.func.isRequired,
};

export default connect()(RedfishServerFirmwareUpdateDialog);
