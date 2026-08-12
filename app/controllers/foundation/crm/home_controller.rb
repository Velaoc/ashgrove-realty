# frozen_string_literal: true

module Foundation
  module Crm
    class HomeController < BaseController
      def show
        ensure_default_pipeline!
        @contacts_count = crm_scope(Contact).count
        @properties_count = crm_scope(Property).count
        @active_properties_count = crm_scope(Property).where(status: "active").count
        @open_deals_count = crm_scope(Opportunity).where(status: "open").count
        @pipeline_value_cents = crm_scope(Opportunity).where(status: "open").sum(:amount_cents)
        @open_tasks = crm_scope(Task).open_tasks.ordered.limit(8)
        @recent_activities = crm_scope(Activity).ordered.limit(12)
      end
    end
  end
end
