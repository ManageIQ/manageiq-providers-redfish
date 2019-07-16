export const selectedPhysicalServers = () => {
  if(ManageIQ.gridChecks && ManageIQ.gridChecks.length > 0){ // Multi-record page
    return ManageIQ.gridChecks;
  } else if(ManageIQ.record.recordId){ // Single-record page
    return [ManageIQ.record.recordId];
  } else{
    return [];
  }
};
