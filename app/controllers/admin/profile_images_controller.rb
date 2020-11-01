module Admin
  class ProfileImagesController < Admin::ApplicationController
    before_action :set_profile_image, only: [:update, :destroy, :force_accepted, :force_rejected]
    before_action :set_profile_images, only: [:pending, :accepted, :rejected]
    before_action :authenticate_admin_user!
    PAGINATES_PER = Settings.paging_per.admin.profile_image

    # GET /profile_images/pending
    def pending
      @profile_images = @profile_images.image_pending
                                       .where.not(image: nil)
                                       .order(:updated_at).page(params[:page]).per(PAGINATES_PER)
                                       .includes(:image_admin_user)
      render action: :index
    end

    # GET /profile_images/accepted
    def accepted
      @profile_images = @profile_images.image_accepted
                                       .where.not(image: nil)
                                       .order(image_confirmed_at: :desc).page(params[:page]).per(PAGINATES_PER)
                                       .includes(:image_admin_user)
      render action: :index
    end

    # GET /profile_images/rejected
    def rejected
      @profile_images = @profile_images.image_rejected
                                       .where.not(image: nil)
                                       .order(image_confirmed_at: :desc).page(params[:page]).per(PAGINATES_PER)
                                       .includes(:image_admin_user)
      render action: :index
    end

    # PATCH/PUT /profile_images/1
    def update
      update_action
      redirect_back(fallback_location: pending_admin_profile_images_path)
    end

    # DELETE /profile_images/1
    def destroy
      p 'destroy_action'
      destroy_action
      redirect_back(fallback_location: pending_admin_profile_images_path)
    end

    # PUT /profile_images/:id/force_accepted
    def force_accepted
      @profile_image.target_force_accepted!(:image)
      redirect_back(fallback_location: pending_admin_profile_images_path)
    end

    # PUT /profile_images/:id/force_rejected
    def force_rejected
      @profile_image.target_force_rejected!(:image, rejected_params[:image_rejected_reason])
      redirect_back(fallback_location: pending_admin_profile_images_path)
    end

    # POST accept all selected items
    def accept_selected
      params[:ids].each do |id|
        params[:id] = id
        set_profile_image
        update_action
      end
      redirect_back(fallback_location: pending_admin_profile_images_path)
    end

    # POST reject all selected items with reason
    def reject_selected
      params[:ids].each do |id|
        params[:id] = id
        set_profile_image
        destroy_action
      end
      redirect_back(fallback_location: pending_admin_profile_images_path)
    end

    private

    def update_action
      @profile_image.image_admin_user_id = current_admin_user.id
      if @profile_image.image_pending?
        @profile_image.target_pending_to_accepted!(:image)
      elsif @profile_image.image_rejected?
        @profile_image.target_rejected_to_accepted!(:image)
      end

      # add
      if @profile_image.image_blanked?
          @profile_image.target_pending_to_accepted!(:image)
      end
      # add end
    end

    def destroy_action
      @profile_image.update(image_admin_user_id: current_admin_user.id)
      if @profile_image.image_pending?
        @profile_image.target_pending_to_rejected!(:image, rejected_params[:image_rejected_reason])
        common_destroying_process(@profile_image) if @profile_image.save!
      elsif @profile_image.image_accepted?
        @profile_image.target_accepted_to_rejected!(:image, rejected_params[:image_rejected_reason])
        common_destroying_process(@profile_image)
      end

      # add
      if @profile_image.image_blanked?
        @profile_image.target_accepted_to_rejected!(:image, rejected_params[:image_rejected_reason])
        common_destroying_process(@profile_image)
      end
      # add end
    end

    def common_destroying_process(profile_image)
      profile_image.user_profile.update_main_image!
      #send_notification('user_notification_mailer.rejected.push.profile_image.image',
      #                  rejected_notification_params)
      #ProfileImageMailer.rejected(profile_image).deliver_later if profile_image.user_profile.user.sendable_notification_mail?
    end

    def accepted_notification_params
      {
        title: I18n.t('notification.profile_image.accepted.title'),
        body: I18n.t('notification.profile_image.accepted.body'),
        notice_type: :normal
      }
    end

    def rejected_notification_params
      {
        title: I18n.t('notification.profile_image.rejected.title'),
        body: format(I18n.t('notification.profile_image.rejected.body'), reason: rejected_params[:image_rejected_reason]),
        notice_type: :normal
      }
    end

    def set_profile_image
      @profile_image = ProfileImage.joins(user_profile: :user).includes(:user_profile).find(params[:id])
    end

    def set_profile_images
      @profile_images = ProfileImage.joins(user_profile: :user).includes(user_profile: :user)
    end

    def rejected_params
      params.require(:profile_image).permit(:image_rejected_reason)
    end

    def send_notification(message, notification_params)
      notification = @profile_image.user.user_notifications.create!(notification_params)
      @profile_image.user.send_push_notification(message, {}, id: notification.id) if @profile_image.user.user_notify.notification_push_notify
    end
  end
end
