# frozen_string_literal: true

# Seeds realistic Ashgrove Realty demo data for the first organization that
# has no CRM data yet. Idempotent; never touches users, passwords, or
# credentials. The same logic runs lazily on first CRM visit in production
# (Foundation::Crm::DemoSeeder).

if defined?(Organizations::Organization) && Organizations::Organization.table_exists?
  org = Organizations::Organization.order(:created_at).first
  Foundation::Crm::DemoSeeder.seed!(org) if org
end
