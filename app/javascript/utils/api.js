export const fetchPxeServers = () => API.get(`/api/pxe_servers?expand=resources&attributes=id,name,uri`);

export const fetchPxeImagesForServer = (serverId) => API.get(`/api/pxe_servers/${serverId}/pxe_images?expand=resources&attributes=id,name,pxe_image_type_id`);

export const fetchTemplatesForPxeImage = (pxeImageId) => API.get(`/api/pxe_images/${pxeImageId}/customization_templates?expand=resources&attributes=id,name`);

export const fetchFirmwareBinariesForServer = (serverId) => API.get(`/api/physical_servers/${serverId}/firmware_binaries?expand=resources&attributes=id,name,description`);

export const createProvisionRequest = (physicalServerIds, pxeImageId, templateId) => API.post(`/api/requests`, {
  options: {
    request_type: 'provision_physical_server',
    src_ids: physicalServerIds,
    pxe_image_id: pxeImageId,
    customization_template_id: templateId
  },
  auto_approve: false
}).then(response => {
  response['results'].forEach(res => window.add_flash(res.message, res.status === 'Ok' ? 'success' : 'error'));
});

export const createFirmwareUpdateRequest = (physicalServerIds, firmwareBinaryId) => API.post(`/api/requests`, {
  options: {
    request_type: 'physical_server_firmware_update',
    src_ids: physicalServerIds,
    firmware_binary_id: firmwareBinaryId
  },
  auto_approve: true
}).then(response => {
  response['results'].forEach(res => window.add_flash(res.message, res.status === 'Ok' ? 'success' : 'error'));
});

export const handleApiError = (self) => {
  return (err) => {
    let msg = __('Unknown API error');
    if(err.data && err.data.error && err.data.error.message) {
      msg = err.data.error.message
    }
    self.setState({loading: false, error: msg});
  };
};

export const handleApiErrorHooks = (setLoading, setError) => {
  return (err) => {
    let msg = __('Unknown API error');
    if(err.data && err.data.error && err.data.error.message) {
      msg = err.data.error.message
    }
    setLoading(false);
    setError(msg);
  };
};

export const newApiLikeError = (msg) => { return { data: { error: { message: msg } } } };
