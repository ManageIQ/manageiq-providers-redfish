Vmdb::Gettext::Domains.add_domain(
  'ManageIQ_Providers_Redfish',
  ManageIQ::Providers::Redfish::Engine.root.join('locale').to_s,
  :po
)
