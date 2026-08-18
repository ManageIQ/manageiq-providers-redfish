export const selectedPhysicalServers = (): (string | number)[] => {
  const gridChecksLength = ManageIQ?.gridChecks?.length;
  if (gridChecksLength && gridChecksLength > 0) {
    // Multi-record page
    return ManageIQ.gridChecks;
  } else if (ManageIQ?.record?.recordId) {
    // Single-record page
    return [ManageIQ.record.recordId];
  } else {
    return [];
  }
};
