# frozen_string_literal: true

module Foundation
  module Crm
    class PropertiesController < BaseController
      before_action :set_property, only: %i[show edit update destroy]

      def index
        scope = crm_scope(Property).includes(:opportunities).ordered
        scope = scope.search(params[:q]) if params[:q].present?
        scope = scope.with_status(params[:status]) if params[:status].present?
        @properties = paginate(scope)
      end

      def show
        @deals = @property.opportunities.includes(:pipeline_stage, :contact).ordered
      end

      def new
        @property = crm_scope(Property).new
      end

      def create
        @property = crm_scope(Property).new(property_params)
        @property.organization = @organization
        if @property.save
          record_created(@property)
          redirect_to crm_property_path(@property), notice: "Property created."
        else
          render :new, status: :unprocessable_content
        end
      end

      def edit; end

      def update
        if @property.update(property_params)
          redirect_to crm_property_path(@property), notice: "Property updated."
        else
          render :edit, status: :unprocessable_content
        end
      end

      def destroy
        @property.destroy!
        redirect_to crm_properties_path, notice: "Property deleted."
      end

      private

      def set_property
        @property = find_crm!(Property)
      end

      def property_params
        params.require(:property).permit(
          :address_line_1, :address_line_2, :city, :state, :postal_code, :country,
          :price_cents, :beds, :baths, :sqft, :property_type, :status,
          :listing_type, :mls_number, :description
        )
      end
    end
  end
end
