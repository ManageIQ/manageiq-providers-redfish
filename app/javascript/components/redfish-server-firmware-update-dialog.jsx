import React, { useState, useEffect } from "react";
import PropTypes from "prop-types";
import { connect } from "react-redux";
import FirmwareUpdate from "./forms/firmware-update"
import { handleApiErrorHooks, fetchFirmwareBinariesForServer, createFirmwareUpdateRequest } from "../utils/api";
import { selectedPhysicalServers } from "../utils/common";

const RedfishServerFirmwareUpdateDialog = (props) => {
  const [loading, setLoading] = useState(true);
  const [firmwareBinaries, setFirmwareBinaries] = useState([]);
  const [error, setError] = useState('');
  const [values, setValues] = useState({});
  const physicalServerIds = selectedPhysicalServers();

  useEffect(() => {
    props.dispatch({
      type: "FormButtons.init",
      payload: {
        newRecord: true,
        pristine: true,
      }
    });
    props.dispatch({
      type: "FormButtons.customLabel",
      payload: __('Apply Firmware')
    });
    if(physicalServerIds.length > 0) {
      fetchBinaries()
    } else {
      setError(__('Please pick at least one physical server and open this popup again.'));
    }
  }, []);

  // Everytime a dropdown value changes we have to update the callback function so that its
  // closure contains the most recent state values.
  useEffect(() => {
    props.dispatch({
      type: "FormButtons.callbacks",
      payload: {
        addClicked: () => createFirmwareUpdateRequest(physicalServerIds, values.firmwareBinary)
      }
    });
  }, [values]);

  const fwBinaryToSelectOption = fwBinary => ({ value: fwBinary.id, label: `${fwBinary.name} (${fwBinary.description})` });

  const fetchBinaries = () => fetchFirmwareBinariesForServer(physicalServerIds[0]).then((fwBinaries) => {
    setFirmwareBinaries(fwBinaries.resources.map(fwBinaryToSelectOption));
    setLoading(false);
  }, handleApiErrorHooks(setLoading, setError));

  const handleFormStateUpdate = (formState) => {
    props.dispatch({
      type: "FormButtons.saveable",
      payload: formState.valid
    });
    props.dispatch({
      type: "FormButtons.pristine",
      payload: formState.pristine
    });
    setValues(() => formState.values);
  };

  if(error) {
    return <p>{error}</p>
  }
  return (
    <FirmwareUpdate
      updateFormState={handleFormStateUpdate}
      physicalServerIds={physicalServerIds}
      firmwareBinaries={firmwareBinaries}
      loading={loading}
      initialValues={values}
    />
  );
};

RedfishServerFirmwareUpdateDialog.propTypes = {
  dispatch: PropTypes.func.isRequired,
};

export default connect()(RedfishServerFirmwareUpdateDialog);
