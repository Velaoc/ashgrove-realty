# frozen_string_literal: true

# Ashgrove Realty demo seed.
#
# Seeds realistic office data for the FIRST organization that has no CRM data
# yet, so a fresh signup on the Holodex demo sees a living office instead of
# empty tables. It is idempotent and never touches users, passwords, or
# credentials. Production teams can delete this file or just let it no-op.

def seed_ashgrove_demo!(organization)
  crm = Foundation::Crm

  return if crm::Contact.for_organization(organization).exists?

  owner = organization.users.order(:created_at).first

  contacts = [
    { first_name: "Maya", last_name: "Chen", email: "maya.chen@example.com", phone: "(415) 555-0134", role: "buyer", title: "First-time buyer" },
    { first_name: "Daniel", last_name: "Okafor", email: "daniel.okafor@example.com", phone: "(415) 555-0177", role: "seller", title: "Seller — Elm St" },
    { first_name: "Priya", last_name: "Raman", email: "priya.raman@example.com", phone: "(510) 555-0149", role: "buyer", title: "Moving from Fremont" },
    { first_name: "Tom", last_name: "Whitfield", email: "tom.whitfield@example.com", phone: "(415) 555-0162", role: "seller", title: "Seller — Maple Ave" },
    { first_name: "Elena", last_name: "Vargas", email: "elena.vargas@example.com", phone: "(650) 555-0118", role: "buyer", title: "Investor" }
  ]

  contact_rows = contacts.map { |attrs| crm::Contact.new(attrs.merge(organization: organization, owner: owner)) }
  contact_rows.each(&:save!)

  properties = [
    { address_line_1: "214 Elm Street", city: "San Francisco", state: "CA", postal_code: "94110", price_cents: 1_285_000, beds: 3, baths: 2, sqft: 1740, property_type: "single_family", status: "active", listing_type: "sale", mls_number: "MLS 423118", description: "Victorian with a renovated kitchen, detached garage, and a south-facing backyard." },
    { address_line_1: "88 Maple Avenue", city: "Berkeley", state: "CA", postal_code: "94704", price_cents: 965_000, beds: 2, baths: 1.5, sqft: 1210, property_type: "condo", status: "active", listing_type: "sale", mls_number: "MLS 429901", description: "Top-floor condo with bay views, in-unit laundry, and one parking space." },
    { address_line_1: "1507 Oakwood Court", city: "San Mateo", state: "CA", postal_code: "94403", price_cents: 1_540_000, beds: 4, baths: 3, sqft: 2310, property_type: "single_family", status: "pending", listing_type: "sale", mls_number: "MLS 431204", description: "Modern farmhouse on a corner lot; pending sale." },
    { address_line_1: "32 Harbor Lane", city: "Sausalito", state: "CA", postal_code: "94965", price_cents: 2_180_000, beds: 3, baths: 2.5, sqft: 1980, property_type: "single_family", status: "active", listing_type: "sale", mls_number: "MLS 433556", description: "Waterfront with a private dock and decks on every level." }
  ]

  property_rows = properties.map { |attrs| crm::Property.new(attrs.merge(organization: organization)) }
  property_rows.each(&:save!)

  pipeline = crm::Pipeline.ensure_default!(organization)
  stages = pipeline.stages.ordered.to_a
  by_name = stages.index_by(&:name)

  deals = [
    { name: "Sale of 214 Elm Street", contact: contact_rows[0], property: property_rows[0], stage: "Showing", amount: 1_285_000, expected_close: 45.days.from_now },
    { name: "Sale of 88 Maple Avenue", contact: contact_rows[2], property: property_rows[1], stage: "Offer", amount: 965_000, expected_close: 60.days.from_now },
    { name: "Sale of 1507 Oakwood Court", contact: contact_rows[1], property: property_rows[2], stage: "Under contract", amount: 1_540_000, expected_close: 30.days.from_now },
    { name: "Harbor Lane buyer search", contact: contact_rows[4], property: nil, stage: "Contacted", amount: 2_000_000, expected_close: 120.days.from_now }
  ]

  deal_rows = deals.map do |attrs|
    crm::Opportunity.new(
      name: attrs[:name],
      organization: organization,
      owner: owner,
      contact: attrs[:contact],
      property: attrs[:property],
      pipeline: pipeline,
      pipeline_stage: by_name[attrs[:stage]],
      amount_cents: attrs[:amount] * 100,
      currency: "USD",
      expected_close_on: attrs[:expected_close].to_date
    )
  end
  deal_rows.each(&:save!)

  notes = [
    [contact_rows[0], "Met at the Elm St open house; pre-approved up to $1.4M and wants a yard."],
    [contact_rows[1], "Empty-nesting; motivated to sell this spring and relocate to Oregon."],
    [contact_rows[2], "Needs to close before the school year starts; flexible on contingencies."],
    [contact_rows[4], "Cash buyer looking for a second rental property in the 94110 area code."]
  ]

  notes.each do |contact, body|
    crm::Note.create!(
      organization: organization,
      author: owner,
      notable: contact,
      body: body
    )
  end
end

org = Organization.order(:created_at).first
seed_ashgrove_demo!(org) if org
