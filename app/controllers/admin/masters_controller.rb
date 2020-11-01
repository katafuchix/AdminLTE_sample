module Admin
  class MastersController < Admin::ApplicationController
    prepend_before_action :set_content_class
    before_action :authenticate_admin_user!
    before_action :set_content, only: %i(show edit update destroy)
    #before_action :admin_only_accessible
    PER = Settings.paging_per.prof_masters.list

    def index
      @contents = @content_class.order(:sort_order).page(params[:page]).per(PER)
    end

    def show
    end

    def new
      @content = @content_class.new
    end

    def edit
    end

    def create
      @content = @content_class.new(master_params)
      @content.save ? success_message(:created) : failure_message
    end

    def update
      @content.update(master_params) ? success_message(:updated) : failure_message
    end

    def destroy
      @content.destroy ? success_message(:deleted) : failure_message
    end

    private

    def success_message(i18n_key)
      flash[:success] = I18n.t(i18n_key, scope: 'prof_master.message')
      redirect_to [:admin, @content]
    end

    def failure_message
      flash[:alert] = @content.errors.full_messages.join('<br/>').html_safe
      redirect_to [:admin, @content]
    end

    def set_content
      @content = @content_class.find(params[:id])
    end

    def master_params
      params.require(params[:type].underscore).permit(:name, :enabled, :sort_order)
    end

    def set_content_class
      @content_class = "Master::#{params[:type]}".constantize
    end
  end
end
