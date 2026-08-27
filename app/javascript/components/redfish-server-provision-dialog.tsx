import React, { useState, useMemo } from "react";
import { useMiqDispatch } from "@@miq-redux/miq-hooks";
import MiqFormRenderer from "@@ddf";

import createSchema from "./server-provision.schema";
import { selectedPhysicalServers } from "../utils/common";
import type {
  FormOptions,
  ServerProvisionFormState,
  OptionType,
  ProvisionFormValues,
  ResourcesResponseType,
  ApiResultsResponseType,
  ApiRequestPayloadType,
} from "./redfish-types";

const fetchPxeServers = (): Promise<OptionType[]> =>
  API.get<ResourcesResponseType>(
    "/api/pxe_servers?expand=resources&attributes=id,name,uri",
  ).then(({ resources }) =>
    resources.map(({ id, name, uri }) => ({
      value: id,
      label: `${name} (${uri})`,
    })),
  );

const fetchPxeImages = (server: string): Promise<OptionType[]> =>
  API.get<ResourcesResponseType>(
    `/api/pxe_servers/${server}/pxe_images?expand=resources&attributes=id,name,pxe_image_type_id`,
  ).then(({ resources }) =>
    resources.map(({ id: value, name: label }) => ({ value, label })),
  );

const fetchCustomizationTemplates = (image: string): Promise<OptionType[]> =>
  API.get<ResourcesResponseType>(
    `/api/pxe_images/${image}/customization_templates?expand=resources&attributes=id,name`,
  ).then(({ resources }) =>
    resources.map(({ id: value, name: label }) => ({ value, label })),
  );

const RedfishServerProvisionDialog: React.FC = () => {
  const dispatch = useMiqDispatch();
  const physicalServerIds = selectedPhysicalServers();
  const [state, setState] = useState<ServerProvisionFormState>({});

  const pxeServerPromise = useMemo(() => fetchPxeServers(), []);
  const pxeImagePromise = useMemo(
    () =>
      state?.pxeServer ? fetchPxeImages(state.pxeServer) : Promise.resolve([]),
    [state?.pxeServer],
  );
  const customizationTemplatePromise = useMemo(
    () =>
      state?.pxeImage
        ? fetchCustomizationTemplates(state.pxeImage)
        : Promise.resolve([]),
    [state?.pxeImage],
  );

  const initialize = (formOptions: FormOptions) => {
    // TODO: Modernize Redux - Convert form-buttons-reducer.js to Redux Toolkit slice
    // This would replace manual action types with auto-generated action creators:
    // dispatch(init({ newRecord: true, pristine: true }));
    // dispatch(customLabel(__("Provision")));
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
      payload: __("Provision"),
    });
    dispatch({
      type: "FormButtons.callbacks",
      payload: { addClicked: () => formOptions.submit() },
    });
  };

  const submitValues = ({
    pxeImage: pxe_image_id,
    customizationTemplate: customization_template_id,
  }: ProvisionFormValues) => {
    const payload: ApiRequestPayloadType = {
      options: {
        request_type: "provision_physical_server",
        src_ids: physicalServerIds,
        pxe_image_id,
        customization_template_id,
      },
      auto_approve: false,
    };

    API.post<ApiResultsResponseType>("/api/requests", payload).then(
      (response) => {
        response.results.forEach((res) =>
          add_flash(res.message, res.status === "Ok" ? "success" : "error"),
        );
      },
    );
  };

  const schema = createSchema(
    pxeServerPromise,
    pxeImagePromise,
    customizationTemplatePromise,
    state,
    setState,
  );

  return (
    <MiqFormRenderer
      schema={schema}
      onSubmit={submitValues}
      showFormControls={false}
      initialize={initialize}
    />
  );
};

export default RedfishServerProvisionDialog;
