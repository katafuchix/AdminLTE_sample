module Admin
  module My
    class BasicInfosController < Admin::ApplicationController
      before_action :authenticate_admin_user!
      before_action :set_instance, only: [:edit, :update]

      def edit
        render file: 'admin/my/basic_infos/form'
      end

      def update
        current_admin_user.update(admin_user_params) ? success_message : failure_message
      end

      private

      def set_instance
        @admin_user = Admin::User.find(current_admin_user.id)
      end

      def admin_user_params
        if params[:admin_user][:password].blank? && params[:admin_user][:password_confirmation].blank?
          params.require(:admin_user).permit(:name, :email)
        else
          params.require(:admin_user).permit(:name, :email, :password, :password_confirmation)
        end
      end

      def success_message
        flash[:notice] = I18n.t('admin/my/basic_infos_controller.update.flash_success')
        bypass_sign_in current_admin_user
        redirect_to edit_admin_my_basic_infos_path
      end

      def failure_message
        flash.now[:alert] = @admin_user.errors.full_messages.join('<br/>').html_safe
        render 'admin/my/basic_infos/form'
      end
    end
  end
end
