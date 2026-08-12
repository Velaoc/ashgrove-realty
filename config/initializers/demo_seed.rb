# frozen_string_literal: true

# Demo bootstrap: seeds Ashgrove Realty demo data on boot for a fresh
# organization so the Holodex preview reads like a working office.
#
# Idempotent: db/seeds.rb skips organizations that already have CRM data,
# and every failure here is swallowed so a missing table or empty database
# can never break boot. Production deployments can delete this file.

begin
  if Rails.env.production? && defined?(Organization) && Organization.table_exists?
    load Rails.root.join("db/seeds.rb")
  end
rescue ActiveRecord::ActiveRecordError, StandardError
  # Boot must never fail because demo seeding did.
end
