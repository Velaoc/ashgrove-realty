# frozen_string_literal: true

class AddPropertyRefToCrmOpportunities < ActiveRecord::Migration[8.0]
  def change
    add_reference :crm_opportunities, :property, foreign_key: { to_table: :crm_properties }
  end
end
