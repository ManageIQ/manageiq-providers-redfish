import RedfishServerProvisionDialog
  from "../components/redfish-server-provision-dialog";
import RedfishServerFirmwareUpdateDialog
  from "../components/redfish-server-firmware-update-dialog";

ManageIQ.component.addReact(
  "RedfishServerProvisionDialog", RedfishServerProvisionDialog
);

ManageIQ.component.addReact(
  "RedfishServerFirmwareUpdateDialog", RedfishServerFirmwareUpdateDialog
);
