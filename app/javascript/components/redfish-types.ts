export type { Dispatch, SetStateAction } from "react";
export type {
  FormOptions,
  MiqFormSchemaType,
  OptionType,
} from "@@miq-types/forms";

type ResourceType = {
  href: string;
  id: string;
  name: string;
  type?: string;
  description?: string;
  uri?: string;
};

export type ResourcesResponseType = {
  resources: ResourceType[];
};

export type ServerProvisionFormState = {
  pxeServer?: string;
  pxeImage?: string;
};

export type ProvisionFormValues = {
  pxeServer?: string;
  pxeImage?: string;
  customizationTemplate?: string;
};

export type FirmwareUpdateFormValues = {
  firmwareBinary?: {
    value?: string;
  };
};

type ApiResultType = {
  message: string;
  status: string;
};

export type ApiResultsResponseType = {
  results: ApiResultType[];
};

type RequestOptionsType = {
  request_type: string;
  src_ids: (string | number)[];
  pxe_image_id?: string;
  customization_template_id?: string;
  firmware_binary_id?: string;
};

export type ApiRequestPayloadType = {
  options: RequestOptionsType;
  auto_approve: boolean;
};
