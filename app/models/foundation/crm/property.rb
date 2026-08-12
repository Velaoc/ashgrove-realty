# frozen_string_literal: true

module Foundation
  module Crm
    class Property < ApplicationRecord
      include OrganizationScoped

      self.table_name = "crm_properties"

      TYPES = %w[
        single_family condo townhouse multi_family land commercial
      ].freeze

      STATUSES = %w[active pending sold off_market].freeze
      LISTING_TYPES = %w[sale rent].freeze

      belongs_to :organization
      has_many :opportunities, class_name: "Foundation::Crm::Opportunity", dependent: :nullify, inverse_of: :property

      validates :address_line_1, presence: true, length: { maximum: 200 }
      validates :address_line_2, length: { maximum: 200 }, allow_blank: true
      validates :city, presence: true, length: { maximum: 120 }
      validates :state, length: { maximum: 80 }, allow_blank: true
      validates :postal_code, length: { maximum: 20 }, allow_blank: true
      validates :country, presence: true, length: { maximum: 2 }
      validates :price_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validates :beds, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
      validates :baths, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
      validates :sqft, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
      validates :property_type, inclusion: { in: TYPES }
      validates :status, inclusion: { in: STATUSES }
      validates :listing_type, inclusion: { in: LISTING_TYPES }
      validates :mls_number, length: { maximum: 60 }, allow_blank: true
      validates :description, length: { maximum: 20_000 }, allow_blank: true

      before_validation :normalize_fields

      scope :ordered, -> { order(:address_line_1, :id) }
      scope :with_status, ->(status) {
        status.to_s.presence_in(STATUSES) ? where(status: status) : all
      }
      scope :search, ->(query) {
        q = query.to_s.strip
        next all if q.blank?

        pattern = "%#{ActiveRecord::Base.sanitize_sql_like(q)}%"
        where(
          "address_line_1 ILIKE :q OR city ILIKE :q OR coalesce(state, '') ILIKE :q OR coalesce(mls_number, '') ILIKE :q",
          q: pattern
        )
      }

      def display_name
        [ address_line_1, city ].compact_blank.join(", ")
      end

      def full_address
        [
          [ address_line_1, address_line_2 ].compact_blank.join(", "),
          [ city, state ].compact_blank.join(", "),
          postal_code,
          country
        ].compact_blank.join(", ")
      end

      private

      def normalize_fields
        self.address_line_1 = address_line_1.to_s.strip
        self.address_line_2 = address_line_2.to_s.strip.presence
        self.city = city.to_s.strip
        self.state = state.to_s.strip.presence
        self.postal_code = postal_code.to_s.strip.presence
        self.country = country.to_s.strip.upcase.presence || "US"
        self.mls_number = mls_number.to_s.strip.presence
        self.description = description.to_s.strip.presence
      end
    end
  end
end
