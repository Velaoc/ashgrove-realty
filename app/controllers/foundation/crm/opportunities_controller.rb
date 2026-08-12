# frozen_string_literal: true

module Foundation
  module Crm
    class OpportunitiesController < BaseController
      before_action :ensure_default_pipeline!
      before_action :set_opportunity, only: %i[show edit update destroy move_stage assign]

      def index
        scope = crm_scope(Opportunity).includes(:pipeline_stage, :owner, :company, :property).ordered
        scope = scope.search(params[:q]) if params[:q].present?
        scope = scope.with_status(params[:status]) if params[:status].present?
        scope = scope.in_stage(params[:stage_id]) if params[:stage_id].present?
        scope = scope.owned_by(current_user) if params[:mine] == "1"
        @stages = @pipeline.stages.ordered
        @opportunities = paginate(scope)
      end

      def show
        load_timeline(@opportunity)
        @stages = @opportunity.pipeline.stages.ordered
        @members = organization_members
      end

      def new
        stage = @pipeline.stages.ordered.first
        @opportunity = crm_scope(Opportunity).new(
          owner: current_user,
          pipeline: @pipeline,
          pipeline_stage: stage,
          currency: "USD"
        )
        load_form_collections
      end

      def create
        @opportunity = crm_scope(Opportunity).new(opportunity_params)
        @opportunity.organization = @organization
        @opportunity.pipeline ||= @pipeline
        if @opportunity.save
          record_created(@opportunity)
          redirect_to crm_opportunity_path(@opportunity), notice: "Deal created."
        else
          load_form_collections
          render :new, status: :unprocessable_content
        end
      end

      def edit
        load_form_collections
      end

      def update
        if @opportunity.update(opportunity_params)
          redirect_to crm_opportunity_path(@opportunity), notice: "Deal updated."
        else
          load_form_collections
          render :edit, status: :unprocessable_content
        end
      end

      def destroy
        @opportunity.destroy!
        redirect_to crm_opportunities_path, notice: "Deal deleted."
      end

      def move_stage
        stage = crm_scope(PipelineStage).find_by(id: params[:pipeline_stage_id], pipeline_id: @opportunity.pipeline_id)
        unless stage
          return redirect_to crm_opportunity_path(@opportunity), alert: "Choose a valid stage."
        end

        @opportunity.move_to_stage!(stage, actor: current_user)
        redirect_to crm_opportunity_path(@opportunity), notice: "Stage updated."
      end

      def assign
        owner_id = params[:owner_id].presence
        owner = owner_id ? organization_members.find_by(id: owner_id) : nil
        if owner_id && owner.nil?
          return redirect_to crm_opportunity_path(@opportunity), alert: "Choose a member of this organization."
        end

        @opportunity.assign_owner!(owner, actor: current_user)
        redirect_to crm_opportunity_path(@opportunity), notice: owner ? "Deal assigned." : "Deal unassigned."
      end

      private

      def set_opportunity
        @opportunity = find_crm!(Opportunity)
      end

      def opportunity_params
        permitted = params.require(:opportunity).permit(
          :name, :amount_cents, :currency, :expected_close_on, :description,
          :pipeline_id, :pipeline_stage_id, :company_id, :contact_id, :property_id, :owner_id
        )
        if permitted[:amount_cents].blank? && params[:opportunity][:amount_dollars].present?
          dollars = params[:opportunity][:amount_dollars].to_s.gsub(/[^\d.]/, "").to_f
          permitted[:amount_cents] = (dollars * 100).round
        end
        pipeline_id = permitted[:pipeline_id].presence || @pipeline.id
        permitted[:pipeline_id] = crm_scope(Pipeline).where(id: pipeline_id).pick(:id)
        if permitted[:pipeline_stage_id].present?
          permitted[:pipeline_stage_id] = crm_scope(PipelineStage)
            .where(id: permitted[:pipeline_stage_id], pipeline_id: permitted[:pipeline_id])
            .pick(:id)
        end
        if permitted[:company_id].present?
          permitted[:company_id] = crm_scope(Company).where(id: permitted[:company_id]).pick(:id)
        end
        if permitted[:contact_id].present?
          permitted[:contact_id] = crm_scope(Contact).where(id: permitted[:contact_id]).pick(:id)
        end
        if permitted[:property_id].present?
          permitted[:property_id] = crm_scope(Property).where(id: permitted[:property_id]).pick(:id)
        end
        if permitted.key?(:owner_id)
          raw = permitted[:owner_id].presence
          permitted[:owner_id] = raw && organization_members.where(id: raw).pick(:id)
        end
        permitted[:currency] = permitted[:currency].to_s.upcase if permitted[:currency]
        permitted
      end

      def load_form_collections
        @pipelines = crm_scope(Pipeline).ordered
        @stages = @pipelines.flat_map(&:stages)
        @companies = crm_scope(Company).ordered
        @contacts = crm_scope(Contact).ordered
        @properties = crm_scope(Property).ordered
        @members = organization_members
      end
    end
  end
end
