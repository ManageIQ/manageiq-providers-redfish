import React, { useState, useEffect } from "react";
import { useMiqDispatch } from "@@miq-redux/miq-hooks";
import MiqFormRenderer from "@@ddf";

import createSchema from "./firmware-update.schema";
import { selectedPhysicalServers } from "../utils/common";
import type {
  FormOptions,
  OptionType,
  FirmwareUpdateFormValues,
  ResourcesResponseType,
  ApiResultsResponseType,
  ApiRequestPayloadType,
} from "./redfish-types";

const RedfishServerFirmwareUpdateDialog: React.FC = () => {
  const dispatch = useMiqDispatch();
  const physicalServerIds = selectedPhysicalServers();
  const [{ firmwareBinaryOptions }, setState] = useState<{
    firmwareBinaryOptions?: OptionType[];
  }>({});

  useEffect(() => {
    API.get<ResourcesResponseType>(
      `/api/physical_servers/${physicalServerIds[0]}/firmware_binaries?expand=resources&attributes=id,name,description`,
    ).then(({ resources }) => {
      const firmwareBinaries: OptionType[] = [];
      resources.forEach((firmwareBinary) => {
        firmwareBinaries.push({
          value: firmwareBinary.id,
          label: `${firmwareBinary.name} (${firmwareBinary.description})`,
        });
      });
      setState({
        firmwareBinaryOptions: firmwareBinaries,
      });
    });
  }, [physicalServerIds]);

  const initialize = (formOptions: FormOptions) => {
    // TODO: Modernize Redux - Convert form-buttons-reducer.js to Redux Toolkit slice
    // This would replace manual action types with auto-generated action creators:
    // dispatch(init({ newRecord: true, pristine: true }));
    // dispatch(customLabel(__("Apply Firmware")));
    // dispatch(callbacks({ addClicked: () => formOptions.submit() }));
    dispatch({
      type: "FormButtons.init",
      payload: {
        newRecord: true,
        pristine: true,
      },
    });
    dispatch({
      type: "FormButtons.customLabel",
      payload: __("Apply Firmware"),
    });
    dispatch({
      type: "FormButtons.callbacks",
      payload: { addClicked: () => formOptions.submit() },
    });
  };

  const submitValues = (formData: FirmwareUpdateFormValues) => {
    if (formData?.firmwareBinary?.value) {
      const payload: ApiRequestPayloadType = {
        options: {
          request_type: "physical_server_firmware_update",
          src_ids: physicalServerIds,
          firmware_binary_id: formData.firmwareBinary.value,
        },
        auto_approve: true,
      };

      API.post<ApiResultsResponseType>("/api/requests", payload).then(
        (response) => {
          response.results.forEach((res) =>
            add_flash(res.message, res.status === "Ok" ? "success" : "error"),
          );
        },
      );
    }
  };

  return (
    <MiqFormRenderer
      schema={createSchema(firmwareBinaryOptions || [])}
      onSubmit={submitValues}
      showFormControls={false}
      initialize={initialize}
    />
  );
};

export default RedfishServerFirmwareUpdateDialog;
