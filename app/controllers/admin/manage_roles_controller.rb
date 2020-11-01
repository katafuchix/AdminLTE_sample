module Admin
  class ManageRolesController < Admin::ApplicationController
    before_action :authenticate_admin_user!
    before_action :set_instance, only: [:edit, :update, :destroy]
    before_action :special_admin_only_accessible

    def index
      @page = params[:page] || 1
      @admin_users = Admin::User.all.page(@page).per(Settings.paging_per.manage_roles.list)
      render file: 'admin/manage_roles/index'
    end

    def new
      @admin_user = Admin::User.new
      render file: 'admin/manage_roles/form'
    end

    def create
      @admin_user = Admin::User.new(admin_user_params)
      @admin_user.save ? success_message(:created) : failure_message
    end

    def edit
      render file: 'admin/manage_roles/form'
    end

    def update
      @admin_user.update(admin_user_params(true)) ? success_message(:updated) : failure_message
    end

    def destroy
      @admin_user.destroy
      flash[:success] = I18n.t('admin_user.message.deleted')
      redirect_to action: :index
    end

    private

    def set_instance
      @admin_user = Admin::User.find(params[:id])
    end

    def admin_user_params(is_update = false)
      if is_update && params[:admin_user][:password].blank? && params[:admin_user][:password_confirmation].blank?
        params.require(:admin_user).permit(:name, :email, :role)
      else
        params.require(:admin_user).permit(:name, :email, :password, :password_confirmation, :role)
      end
    end

    def success_message(i18n_key)
      flash[:success] = I18n.t(i18n_key, scope: 'admin_user.message')
      redirect_to action: :index
    end

    def failure_message
      flash.now[:alert] = @admin_user.errors.full_messages.join('<br/>').html_safe
      render file: 'admin/manage_roles/form'
    end
  end
end
