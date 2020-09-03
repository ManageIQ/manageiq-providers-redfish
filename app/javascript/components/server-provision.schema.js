import { componentTypes, validatorTypes } from '@@ddf';

// FIXME: there's a bug in the current DDF version that doesn't allow us to use react state together
// with dynamically loaded dropdown values if the dropdown is searchable. A newer version of DDF woll
// fix this problem, so we can enable isSearchable below after we are running the latest version.

const createSchema = (pxeServerPromise, pxeImagePromise, customizationTemplatePromise) => ({
  fields: [
    {
      component: componentTypes.SELECT,
      id: 'pxeServer',
      name: 'pxeServer',
      label: __('PXE Server'),
      placeholder: __('Select a PXE Server'),
      // isSearchable: true,
      isRequired: true,
      validate: [{
        type: validatorTypes.REQUIRED,
        message: __('PXE Server is required'),
      }],
      loadOptions: () => pxeServerPromise,
    },
    {
      component: componentTypes.SELECT,
      id: 'pxeImage',
      name: 'pxeImage',
      label: __('PXE Image'),
      placeholder: __('Select a PXE Image'),
      // isSearchable: true,
      isRequired: true,
      validate: [{
        type: validatorTypes.REQUIRED,
        message: __('PXE Image is required'),
      }],
      condition: {
        when: 'pxeServer',
        isNotEmpty: true,
      },
      loadOptions: () => pxeImagePromise,
    },
    {
      component: componentTypes.SELECT,
      id: 'customizationTemplate',
      name: 'customizationTemplate',
      label: __('Customization Template'),
      placeholder: __('Select a Customization Template'),
      // isSearchable: true,
      isRequired: true,
      validate: [{
        type: validatorTypes.REQUIRED,
        message: __('Customization Template is required'),
      }],
      condition: {
        when: 'pxeImage',
        isNotEmpty: true,
      },
      loadOptions: () => customizationTemplatePromise,
    }
  ],
});

export default createSchema;
