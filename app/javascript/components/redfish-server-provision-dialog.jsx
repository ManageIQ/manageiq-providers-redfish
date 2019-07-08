import React from "react";
import PropTypes from "prop-types";
import { connect } from "react-redux";
import PxeDetails from "./forms/pxe-details"
import { handleApiError, fetchPxeServers, fetchPxeImagesForServer, fetchTemplatesForPxeImage,
  createProvisionRequest
} from "../utils/api";

class RedfishServerProvisionDialog extends React.Component {
  constructor(props) {
    super(props);
    this.handleFormStateUpdate = this.handleFormStateUpdate.bind(this);
    this.state = {
      loading: true,
      physicalServerIds: [],
      pxeServers: [],
      pxeImages: [],
      customizationTemplates: [],
    }
  }

  selectedPhysicalServers = () => {
    if(ManageIQ.gridChecks && ManageIQ.gridChecks.length > 0){ // Multi-record page
      this.setState({physicalServerIds: ManageIQ.gridChecks});
    } else if(ManageIQ.record.recordId){ // Single-record page
      this.setState({physicalServerIds: [ManageIQ.record.recordId]});
    } else{
      this.setState({physicalServerIds: [], error: __('Please select at lest one physical server to provision.')});
    }
  };

  pxeServerToSelectOption = pxeServer => { return { value: pxeServer.id, label: `${pxeServer.name} (${pxeServer.uri})` } };
  pxeImageToSelectOption = pxeImage => { return { value: pxeImage.id, label: pxeImage.name } };
  templateToSelectOption = template => { return { value: template.id, label: template.name } };

  initializeData = () => fetchPxeServers().then((pxeServers) => {
      this.setState({
        pxeServers: pxeServers.resources.map(this.pxeServerToSelectOption),
        loading: false
      });
    }, handleApiError(this));

  onChange = (formState) => {
    if(formState.modified.pxeServer){
      this.setState({customizationTemplates: []});
      fetchPxeImagesForServer(formState.values.pxeServer).then(images => {
        this.setState({pxeImages: images.resources.map(this.pxeImageToSelectOption)});
      }, handleApiError(this));
    } else if(formState.modified.pxeImage){
      fetchTemplatesForPxeImage(formState.values.pxeImage).then(templates => {
        this.setState({customizationTemplates: templates.resources.map(this.templateToSelectOption)});
      }, handleApiError(this));
    }
  };

  componentDidMount() {
    this.props.dispatch({
      type: "FormButtons.init",
      payload: {
        newRecord: true,
        pristine: true,
        addClicked: () => createProvisionRequest(
          this.state.physicalServerIds, this.state.values.pxeImage, this.state.values.customizationTemplate
        )
      }
    });
    this.props.dispatch({
      type: "FormButtons.customLabel",
      payload: __('Provision')
    });
    this.selectedPhysicalServers();
    this.initializeData()
  }

  handleFormStateUpdate(formState) {
    this.props.dispatch({
      type: "FormButtons.saveable",
      payload: formState.valid
    });
    this.props.dispatch({
      type: "FormButtons.pristine",
      payload: formState.pristine
    });
    this.setState({
      values: formState.values
    });
    this.onChange(formState);
  }

  render() {
    if(this.state.error) {
      return <p>{this.state.error}</p>
    }
    return (
      <PxeDetails
        updateFormState={this.handleFormStateUpdate}
        physicalServerIds={this.state.physicalServerIds}
        pxeServers={this.state.pxeServers}
        pxeImages={this.state.pxeImages}
        customizationTemplates={this.state.customizationTemplates}
        loading={this.state.loading}
        initialValues={this.state.values}
      />
    );
  }
}

RedfishServerProvisionDialog.propTypes = {
  dispatch: PropTypes.func.isRequired,
};

export default connect()(RedfishServerProvisionDialog);
