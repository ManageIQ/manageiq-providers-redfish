import React, { useState, useEffect, useMemo } from "react";
import PropTypes from "prop-types";
import { connect } from "react-redux";
import MiqFormRenderer from '@@ddf';

import createSchema from './server-provision.schema';
import { selectedPhysicalServers } from "../utils/common";

const fetchPxeServers = () => API.get(`/api/pxe_servers?expand=resources&attributes=id,name,uri`).then(({ resources }) =>
  resources.map(({ id, name, uri }) => ({ value: id, label: `${name} (${uri})`}))
);

const fetchPxeImages = (server) => API.get(`/api/pxe_servers/${server}/pxe_images?expand=resources&attributes=id,name,pxe_image_type_id`).then(({ resources }) =>
  resources.map(({ id: value, name: label }) => ({ value, label }))
);

const fetchcustomizationTemplates = (image) => API.get(`/api/pxe_images/${image}/customization_templates?expand=resources&attributes=id,name`).then(({ resources }) =>
  resources.map(({ id: value, name: label }) => ({ value, label }))
);

const RedfishServerProvisionDialog = ({ dispatch }) => {
  const physicalServerIds = selectedPhysicalServers();
  const [{ pxeServer, pxeImage }, setState] = useState({});

  const pxeServerPromise = useMemo(() => fetchPxeServers());
  const pxeImagePromise = useMemo(() => pxeServer ? fetchPxeImages(pxeServer) : undefined, [pxeServer]);
  const customizationTemplatePromise = useMemo(() => pxeImage ? fetchcustomizationTemplates(pxeImage) : undefined, [pxeImage]);

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
      payload: __('Provision'),
    });
  }, []);

  const submitValues = ({ pxeImage: pxe_image_id, customizationTemplate: customization_template_id }) => {
    API.post(`/api/requests`, {
      options: {
        request_type: 'provision_physical_server',
        src_ids: physicalServerIds,
        pxe_image_id,
        customization_template_id,
      },
      auto_approve: false,
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

    if (formState.modified.pxeServer && pxeServer !== formState.values.pxeServer) {
      setState(state => ({ ...state, pxeServer: formState.values.pxeServer }));
    };

    if (formState.modified.pxeImage && pxeImage !== formState.values.pxeImage) {
      setState(state => ({ ...state, pxeImage: formState.values.pxeImage }));
    };
  };

  const schema = createSchema(pxeServerPromise, pxeImagePromise, customizationTemplatePromise);

  return (
    <MiqFormRenderer
      schema={schema}
      onSubmit={submitValues}
      showFormControls={false}
      onStateUpdate={handleFormStateUpdate}
    />
  );
};

RedfishServerProvisionDialog.propTypes = {
  dispatch: PropTypes.func.isRequired,
};

export default connect()(RedfishServerProvisionDialog);
