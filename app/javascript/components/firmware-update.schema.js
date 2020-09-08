import { componentTypes, validatorTypes } from '@@ddf';

const createSchema = (fetchPromise) => ({
  fields: [{
    component: componentTypes.SELECT,
    id: 'firmwareBinary',
    name: 'firmwareBinary',
    label: __('Firmware Binary'),
    placeholder: __('Select a Firmware Binary'),
    isSearchable: true,
    isRequired: true,
    validate: [{
      type: validatorTypes.REQUIRED,
      message: __('Firmware Binary is required'),
    }],
    loadOptions: () => fetchPromise,
  }],
});

export default createSchema;
