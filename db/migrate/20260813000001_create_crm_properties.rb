# frozen_string_literal: true

class CreateCrmProperties < ActiveRecord::Migration[8.0]
  def change
    create_table :crm_properties do |t|
      t.references :organization, null: false, index: false
      t.string :address_line_1, null: false, default: ""
      t.string :address_line_2, default: ""
      t.string :city, null: false, default: ""
      t.string :state, default: ""
      t.string :postal_code, default: ""
      t.string :country, default: "US"
      t.integer :price_cents, default: 0, null: false
      t.decimal :beds, precision: 4, scale: 1, default: 0
      t.decimal :baths, precision: 4, scale: 1, default: 0
      t.integer :sqft, default: 0
      t.string :property_type, default: "single_family", null: false
      t.string :status, default: "active", null: false
      t.string :listing_type, default: "sale", null: false
      t.string :mls_number, default: ""
      t.text :description
      t.timestamps
    end

    add_index :crm_properties, [ :organization_id, :status ]
  end
end
