module Admin
  module My
    class NotifySettingsController < Admin::ApplicationController
      before_action :authenticate_admin_user!
      before_action :set_instance, only: [:edit, :update]

      def edit
        render file: 'admin/my/notify_settings/form'
      end

      def update
        current_admin_user.user_notify.update(user_notify_params) ? success_message : failure_message
      end

      private

      def set_instance
        @admin_user_notify = Admin::UserNotify.find_or_create_by!(user_id: current_admin_user.id)
      end

      def user_notify_params
        if current_admin_user.role == 'operator'
          params.require(:admin_user_notify).permit(:user_certification_notify, :profile_image_notify, :user_profile_notify)
        else
          params.require(:admin_user_notify).permit(:user_certification_notify, :profile_image_notify, :user_profile_notify,
                                                    :inquiry_notify)
        end
      end

      def success_message
        flash[:notice] = I18n.t('admin/my/notify_settings_controller.update.flash_success')
        redirect_to edit_admin_my_notify_settings_path
      end

      def failure_message
        flash.now[:alert] = @admin_user_notify.errors.full_messages.join('<br/>').html_safe
        render 'admin/my/notify_settings/form'
      end
    end
  end
end
