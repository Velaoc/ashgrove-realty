# frozen_string_literal: true

module Foundation
  module Crm
    # Seeds realistic Ashgrove Realty demo data for an organization the first
    # time a member opens the CRM, so the Holodex preview reads like a working
    # office instead of empty tables. Idempotent, org-scoped, and only ever
    # creates data — never users, passwords, or credentials.
    class DemoSeeder
      def self.seed!(organization)
        new(organization).seed!
      end

      def initialize(organization)
        @organization = organization
      end

      def seed!
        return if Contact.for_organization(@organization).exists?

        owner = @organization.users.order(:created_at).first
        return unless owner

        seed_contacts!
        seed_properties!
        seed_pipeline!
        seed_deals!
        seed_notes!
      end

      private

      def seed_contacts!
        contacts.each { |attrs| Contact.create!(attrs.merge(organization: @organization, owner: @owner)) }
      end

      def seed_properties!
        properties.each { |attrs| Property.create!(attrs.merge(organization: @organization)) }
      end

      def seed_pipeline!
        @pipeline = Pipeline.ensure_default!(@organization)
        @stages = @pipeline.stages.ordered.index_by(&:name)
      end

      def seed_deals!
        deals.each do |attrs|
          Opportunity.create!(
            name: attrs[:name],
            organization: @organization,
            owner: @owner,
            contact: attrs[:contact],
            property: attrs[:property],
            pipeline: @pipeline,
            pipeline_stage: @stages[attrs[:stage]],
            amount_cents: attrs[:amount] * 100,
            currency: "USD",
            expected_close_on: attrs[:expected_close].to_date
          )
        end
      end

      def seed_notes!
        notes.each do |contact, body|
          Note.create!(organization: @organization, author: @owner, notable: contact, body: body)
        end
      end

      def contacts
        @owner = @organization.users.order(:created_at).first
        [
          { first_name: "Maya", last_name: "Chen", email: "maya.chen@example.com", phone: "(415) 555-0134", role: "buyer", title: "First-time buyer" },
          { first_name: "Daniel", last_name: "Okafor", email: "daniel.okafor@example.com", phone: "(415) 555-0177", role: "seller", title: "Seller — Elm St" },
          { first_name: "Priya", last_name: "Raman", email: "priya.raman@example.com", phone: "(510) 555-0149", role: "buyer", title: "Moving from Fremont" },
          { first_name: "Tom", last_name: "Whitfield", email: "tom.whitfield@example.com", phone: "(415) 555-0162", role: "seller", title: "Seller — Maple Ave" },
          { first_name: "Elena", last_name: "Vargas", email: "elena.vargas@example.com", phone: "(650) 555-0118", role: "buyer", title: "Investor" }
        ]
      end

      def properties
        [
          { address_line_1: "214 Elm Street", city: "San Francisco", state: "CA", postal_code: "94110", price_cents: 1_285_000, beds: 3, baths: 2, sqft: 1740, property_type: "single_family", status: "active", listing_type: "sale", mls_number: "MLS 423118", description: "Victorian with a renovated kitchen, detached garage, and a south-facing backyard." },
          { address_line_1: "88 Maple Avenue", city: "Berkeley", state: "CA", postal_code: "94704", price_cents: 965_000, beds: 2, baths: 1.5, sqft: 1210, property_type: "condo", status: "active", listing_type: "sale", mls_number: "MLS 429901", description: "Top-floor condo with bay views, in-unit laundry, and one parking space." },
          { address_line_1: "1507 Oakwood Court", city: "San Mateo", state: "CA", postal_code: "94403", price_cents: 1_540_000, beds: 4, baths: 3, sqft: 2310, property_type: "single_family", status: "pending", listing_type: "sale", mls_number: "MLS 431204", description: "Modern farmhouse on a corner lot; pending sale." },
          { address_line_1: "32 Harbor Lane", city: "Sausalito", state: "CA", postal_code: "94965", price_cents: 2_180_000, beds: 3, baths: 2.5, sqft: 1980, property_type: "single_family", status: "active", listing_type: "sale", mls_number: "MLS 433556", description: "Waterfront with a private dock and decks on every level." }
        ]
      end

      def deals
        [
          { name: "Sale of 214 Elm Street", contact: contact(:maya), property: property(0), stage: "Showing", amount: 1_285_000, expected_close: 45.days.from_now },
          { name: "Sale of 88 Maple Avenue", contact: contact(:priya), property: property(1), stage: "Offer", amount: 965_000, expected_close: 60.days.from_now },
          { name: "Sale of 1507 Oakwood Court", contact: contact(:daniel), property: property(2), stage: "Under contract", amount: 1_540_000, expected_close: 30.days.from_now },
          { name: "Harbor Lane buyer search", contact: contact(:elena), property: nil, stage: "Contacted", amount: 2_000_000, expected_close: 120.days.from_now }
        ]
      end

      def notes
        [
          [ contact(:maya), "Met at the Elm St open house; pre-approved up to $1.4M and wants a yard." ],
          [ contact(:daniel), "Empty-nesting; motivated to sell this spring and relocate to Oregon." ],
          [ contact(:priya), "Needs to close before the school year starts; flexible on contingencies." ],
          [ contact(:elena), "Cash buyer looking for a second rental property in the 94110 area code." ]
        ]
      end

      def contact_rows
        @contact_rows ||= Contact.for_organization(@organization).ordered.to_a
      end

      def property_rows
        @property_rows ||= Property.for_organization(@organization).ordered.to_a
      end

      def contact(key)
        index = { maya: 0, daniel: 1, priya: 2, tom: 3, elena: 4 }.fetch(key)
        contact_rows[index]
      end

      def property(index)
        property_rows[index]
      end
    end
  end
end
