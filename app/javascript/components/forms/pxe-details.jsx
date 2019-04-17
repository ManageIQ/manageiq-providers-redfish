import React, { Component } from "react";
import { Form, Field, FormSpy } from "react-final-form";
import { Form as PfForm, Grid, Button, Col, Row, Spinner } from "patternfly-react";
import PropTypes from "prop-types";
import { required } from "redux-form-validators";

import { FinalFormField, FinalFormSelect } from "@manageiq/react-ui-components/dist/forms";
import '@manageiq/react-ui-components/dist/forms.css';

const PxeDetails = ({loading, updateFormState, physicalServerIds, initialValues, pxeServers, pxeImages,
                      customizationTemplates}) => {
  if(loading){
    return (
      <Spinner loading size="lg" />
    );
  }

  return (
    <Form
      onSubmit={() => {}} // handled by modal
      initialValues={initialValues}
      render={({ handleSubmit }) => (
        <PfForm horizontal>
          <FormSpy onChange={state => updateFormState({ ...state, values: state.values })} />
          <Grid fluid>
            <Row>
              <Col xs={12}>
                <h2>{__(`Number of servers to be provisioned: ${physicalServerIds.length}`)}</h2>
              </Col>
            </Row>
            <hr />
            <Row>
              <Col xs={12}>
                <Field
                  name="pxeServer"
                  component={FinalFormSelect}
                  placeholder={__('Select a PXE Server')}
                  options={pxeServers}
                  label={__('PXE Server')}
                  validateOnMount={false}
                  validate={required({ msg: 'PXE Server is required' })}
                  labelColumnSize={3}
                  inputColumnSize={8}
                  searchable
                />
              </Col>
              <Col xs={12}>
                <Field
                  name="pxeImage"
                  component={FinalFormSelect}
                  placeholder={__('Select a PXE Image')}
                  options={pxeImages}
                  disabled={pxeImages.length === 0}
                  label={__('PXE Image')}
                  validateOnMount={false}
                  validate={required({ msg: 'PXE Image is required' })}
                  labelColumnSize={3}
                  inputColumnSize={8}
                  searchable
                />
              </Col>
              <Col xs={12}>
                <Field
                  name="customizationTemplate"
                  component={FinalFormSelect}
                  placeholder={__('Select Customization Template')}
                  options={customizationTemplates}
                  disabled={customizationTemplates.length === 0}
                  label={__('Customization Template')}
                  validateOnMount={false}
                  validate={required({ msg: 'Customization Template is required' })}
                  labelColumnSize={3}
                  inputColumnSize={8}
                  searchable
                />
              </Col>
              <hr />
            </Row>
          </Grid>
        </PfForm>
      )}
    />
  );
};

PxeDetails.propTypes = {
  updateFormState: PropTypes.func.isRequired,
  physicalServerIds: PropTypes.array.isRequired,
  pxeServers: PropTypes.array.isRequired,
  pxeImages: PropTypes.array.isRequired,
  customizationTemplates: PropTypes.array.isRequired,
  loading: PropTypes.bool.isRequired
};

PxeDetails.defaultProps = {
  loading: false,
};

export default PxeDetails;
