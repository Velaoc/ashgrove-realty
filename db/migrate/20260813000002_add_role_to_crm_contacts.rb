# frozen_string_literal: true

class AddRoleToCrmContacts < ActiveRecord::Migration[8.0]
  def change
    add_column :crm_contacts, :role, :string, default: "other", null: false
  end
end
