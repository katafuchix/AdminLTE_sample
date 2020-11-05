module Admin
  class Admin::AppConfigsController < Admin::ApplicationController
    before_action :authenticate_admin_user!
    before_action :load_config, only: %i(edit update)

    def edit
    end

    def update
      ActiveRecord::Base.transaction do
        #@config.update!(update_params)
        #redirect_to edit_admin_config_path, notice: I18n.t('admin.data_updated')
        @config.update(update_params) ? success_message(:updated) : failure_message
      end
    end

    private

    def success_message(i18n_key)
      flash[:success] = I18n.t(i18n_key, scope: 'admin_user.message')
      redirect_to action: :edit
    end

    def failure_message
      flash.now[:alert] = @admin_user.errors.full_messages.join('<br/>').html_safe
      render template: 'admin/manage_roles/form'
    end

    def load_config
      @config = AppConfig.first_or_initialize
    end

    def permitted_params
      params.require(:app_config).permit(
        :android_point_price_json_production,
        :android_point_price_json_develop,
        :android_member_price_json_production,
        :android_member_price_json_develop,
        :android_min_supported_app_version_on_develop,
        :android_min_supported_app_version_on_production,
        :android_is_maintenance_on_develop,
        :android_is_maintenance_on_production,
        :android_maintenance_message,
        :android_profile_image_register_first,
        :ios_point_price_json_prodution,
        :ios_point_price_json_develop,
        :ios_member_price_json_prodution,
        :ios_member_price_json_develop,
        :ios_force_update_prodution,
        :ios_force_update_develop,
        :ios_force_update_version_prodution,
        :ios_force_update_version_develop,
        :ios_is_maintenance_on_production,
        :ios_is_maintenance_on_develop,
        :ios_maintenance_message,
        :ng_words,
        :is_required_profile_point,
        :is_required_profile_basic,
        :is_required_profile_introduction,
        :is_required_profile_tweet,
        :is_required_profile_image,
      )
    end

    def update_params
      permitted_params
    end

  end
end
