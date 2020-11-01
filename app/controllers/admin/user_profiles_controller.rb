module Admin
  class UserProfilesController < Admin::ApplicationController
    before_action :authenticate_admin_user!
    before_action :set_user_profile, only: [:update, :destroy]
    before_action :set_target_column, except: :index
    PAGINATES_PER = Settings.paging_per.admin.user_profile
    ITEM_NAME = {
      comment:     '自己紹介文',
      good_place:  'よく行く場所',
      date_place:  '初回デートで行きたい場所',
      dream:       '将来の夢',
      school_name: '学校名',
      hobby:       '好きなこと・趣味',
      job_name:    '職業名',
      tweet:       '一言コメント'
    }.freeze

    # GET /user_profiles/#{target_column}/pending
    def pending
      @user_profiles = UserProfile.public_send("#{@target_column}_pending")
                                  .where.not(@target_column => nil)
                                  .order(:updated_at)
                                  .joins(:user).includes(:user, UserProfile.eager_loading_list)
                                  .includes(user: [:user_payments, :user_age_certification])
                                  .page(params[:page]).per(PAGINATES_PER)
                                  .includes("#{@target_column}_admin_user".to_sym)
      render action: :index
    end

    # GET /user_profiles/#{target_column}/accepted
    def accepted
      @user_profiles = UserProfile.public_send("#{@target_column}_accepted")
                                  .where.not(@target_column => nil)
                                  .order("#{@target_column}_confirmed_at" => :desc)
                                  .joins(:user).includes(:user, UserProfile.eager_loading_list)
                                  .includes(user: [:user_payments, :user_age_certification])
                                  .page(params[:page]).per(PAGINATES_PER)
                                  .includes("#{@target_column}_admin_user".to_sym)
      render action: :index
    end

    # GET /user_profiles/#{target_column}/rejected
    def rejected
      @user_profiles = UserProfile.public_send("#{@target_column}_rejected")
                                  .where.not(@target_column => nil)
                                  .order("#{@target_column}_confirmed_at" => :desc)
                                  .joins(:user).includes(:user, UserProfile.eager_loading_list)
                                  .includes(user: [:user_payments, :user_age_certification])
                                  .page(params[:page]).per(PAGINATES_PER)
                                  .includes("#{@target_column}_admin_user".to_sym)
      render action: :index
    end

    # PATCH/PUT /user_profiles/#{target_column}/1
    def update
      update_action
      redirect_back(fallback_location: public_send("pending_admin_user_profiles_#{@target_column}_index_path"))
    end

    # DELETE /user_profiles/#{target_column}/1
    def destroy
      destroy_action
      redirect_back(fallback_location: public_send("pending_admin_user_profiles_#{@target_column}_index_path"))
    end

    # POST accept all selected items
    def accept_selected
      set_target_column
      params[:ids].each do |id|
        params[:id] = id
        set_user_profile
        update_action
      end
      redirect_back(fallback_location: public_send("pending_admin_user_profiles_#{@target_column}_index_path"))
    end

    # POST reject all selected items with reason
    def reject_selected
      set_target_column
      params[:ids].each do |id|
        params[:id] = id
        set_user_profile
        destroy_action
      end
      redirect_back(fallback_location: public_send("pending_admin_user_profiles_#{@target_column}_index_path"))
    end

    def set_user_profile
      @user_profile = UserProfile.joins(:user).includes(:user).find(params[:id])
    end

    def set_target_column
      @target_column = params[:target_column] || request.url.match(%r{#{controller_name}\/(.*)\/})[1]
    end

    private

    def update_action
      @user_profile.public_send("#{@target_column}_admin_user_id=", current_admin_user.id)
      if @user_profile.public_send("#{@target_column}_pending?")
        @user_profile.target_pending_to_accepted!(@target_column.to_sym)
      elsif @user_profile.public_send("#{@target_column}_rejected?")
        @user_profile.target_rejected_to_accepted!(@target_column.to_sym)
      end
    end

    def destroy_action
      @user_profile.public_send("#{@target_column}_admin_user_id=", current_admin_user.id)
      if @user_profile.public_send("#{@target_column}_pending?")
        if @user_profile.target_pending_to_rejected!(@target_column.to_sym, rejected_params["#{@target_column}_rejected_reason".to_sym])
          send_notification_on_destroy
        end
      elsif @user_profile.public_send("#{@target_column}_accepted?")
        if @user_profile.target_accepted_to_rejected!(@target_column.to_sym, rejected_params["#{@target_column}_rejected_reason"].to_sym)
          send_notification_on_destroy
        end
      end
    end

    def send_notification_on_destroy
      @user_profile.public_send("#{@target_column}_rejected!")
      @user_profile.user.user_notifications.create!(rejected_notification_params)
    end

    def accepted_notification_params
      {
        title: format(I18n.t('notification.profile.accepted.title'), type: ITEM_NAME[@target_column.to_sym]),
        body: format(I18n.t('notification.profile.accepted.body'), type: ITEM_NAME[@target_column.to_sym]),
        notice_type: :normal
      }
    end

    def rejected_notification_params
      {
        title: format(I18n.t('notification.profile.rejected.title'), type: ITEM_NAME[@target_column.to_sym]),
        body: format(I18n.t('notification.profile.rejected.body'),
                     type: ITEM_NAME[@target_column.to_sym],
                     reason: rejected_params["#{@target_column}_rejected_reason".to_sym]),
        notice_type: :normal
      }
    end

    def rejected_params
      params.require(:user_profile).permit("#{@target_column}_rejected_reason".to_sym)
    end
  end
end
