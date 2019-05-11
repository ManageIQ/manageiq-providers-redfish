export const fetchPxeServers = () => API.get(`/api/pxe_servers?expand=resources&attributes=id,name,uri`);

export const fetchPxeImagesForServer = (serverId) => API.get(`/api/pxe_servers/${serverId}/pxe_images?expand=resources&attributes=id,name,pxe_image_type_id`);

export const fetchTemplatesForPxeImage = (pxeImageId) => API.get(`/api/pxe_images/${pxeImageId}/customization_templates?expand=resources&attributes=id,name`);

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

export const handleApiError = (self) => {
  return (err) => {
    let msg = __('Unknown API error');
    if(err.data && err.data.error && err.data.error.message) {
      msg = err.data.error.message
    }
    self.setState({loading: false, error: msg});
  };
};

export const newApiLikeError = (msg) => { return { data: { error: { message: msg } } } };