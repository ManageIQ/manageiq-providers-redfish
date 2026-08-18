import { componentTypes, validatorTypes } from "@@ddf";
import type {
  MiqFormSchemaType,
  OptionType,
  ServerProvisionFormState,
  Dispatch,
  SetStateAction,
} from "./redfish-types";

const createSchema = (
  pxeServerPromise: Promise<OptionType[]>,
  pxeImagePromise: Promise<OptionType[]>,
  customizationTemplatePromise: Promise<OptionType[]>,
  state: ServerProvisionFormState,
  setState: Dispatch<SetStateAction<ServerProvisionFormState>>,
): MiqFormSchemaType => ({
  fields: [
    {
      component: componentTypes.SELECT,
      id: "pxeServer",
      name: "pxeServer",
      label: __("PXE Server"),
      placeholder: __("Select a PXE Server"),
      isRequired: true,
      validate: [
        {
          type: validatorTypes.REQUIRED,
          message: __("PXE Server is required"),
        },
      ],
      loadOptions: () => pxeServerPromise,
      includeEmpty: true,
      onChange: (value) => {
        setState({ ...state, pxeServer: value as string });
      },
    },
    {
      component: componentTypes.SELECT,
      id: "pxeImage",
      name: "pxeImage",
      label: __("PXE Image"),
      placeholder: __("Select a PXE Image"),
      isRequired: true,
      validate: [
        {
          type: validatorTypes.REQUIRED,
          message: __("PXE Image is required"),
        },
      ],
      condition: {
        when: "pxeServer",
        isNotEmpty: true,
      },
      loadOptions: () => pxeImagePromise,
      includeEmpty: true,
      onChange: (value) => {
        setState({ ...state, pxeImage: value as string });
      },
    },
    {
      component: componentTypes.SELECT,
      id: "customizationTemplate",
      name: "customizationTemplate",
      key: `pxeImage-${state.pxeImage}`,
      label: __("Customization Template"),
      placeholder: __("Select a Customization Template"),
      isRequired: true,
      validate: [
        {
          type: validatorTypes.REQUIRED,
          message: __("Customization Template is required"),
        },
      ],
      condition: {
        when: "pxeImage",
        isNotEmpty: true,
      },
      includeEmpty: true,
      loadOptions: () => customizationTemplatePromise,
    },
  ],
});

export default createSchema;
