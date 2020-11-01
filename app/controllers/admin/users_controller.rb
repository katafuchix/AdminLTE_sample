module Admin
  class UsersController < Admin::ApplicationController
    before_action :authenticate_admin_user!
    before_action :set_user, only: [:show, :destroy, :edit, :update, :premium_charging, :purchase_payingmember, :purchase_point,
                                    :add_relation_count, :send_notification, :update_profile, :restore_soft_destroy, :toggle_search_status, :profile_image_destroy]
    before_action :set_purchase_options
    before_action :set_relation_count_options
    before_action :admin_only_accessible
    before_action :set_user_matches, only: [:show]
    before_action :special_admin_only_accessible, only: [:index], if: proc { params[:format] == 'csv' }
    include Logic::User::ProfileSearch
    include Admin::UserSearch
    PAGINATES_PER = Settings.paging_per.admin.user
    # GET /users
    def index
      if params[:format] == 'csv'
        @users = filtered_users(params).includes(user_profile: ::UserProfile.eager_loading_list)
                                       .order(params[:sorts] || 'users.last_sign_in_at desc')
                                       .page(params[:page]).per(index_paginates_per)
      else
        @users = filtered_users(params).includes(:user_payments, :user_app_version_info, user_profile: ::UserProfile.eager_loading_list)
                                       .order(params[:sorts] || 'users.last_sign_in_at desc')
                                       .page(params[:page]).per(index_paginates_per)
      end
      @pater_points = ::User.sum_remain_point_with_user(@users.pluck(:id))
      render :fb if params[:fb].present?
    end

    # GET /users/1
    def show
    end

    # DELETE /users/1
    def destroy
      @user.withdrawal!(params[:message])
      @user.update(is_forced_withdrawal: true) if params[:is_forced_withdrawal] == 'true'
      redirect_back(fallback_location: admin_users_path)
    end

    # DELETE /users/1/profile_images_destroy
    def profile_image_destroy
      ::ProfileImage.where(user_profile_id: @user.user_profile.id).destroy_all
      redirect_back(fallback_location: admin_users_path)
    end

    # GET /users/1/edit
    def edit
      @user_profile = UserProfile.find_by(user_id: params[:id])
    end

    # PUT /users/1
    def update
      ActiveRecord::Base.transaction do
        update_email = @user.email != adjust_update_params[:email]
        @user.update!(adjust_update_params)
        # メール更新する場合はconfirm処理
        ::User.confirm_by_token(@user.confirmation_token) if update_email
        flash[:notice] = 'ユーザー情報を更新しました。'
        redirect_back(fallback_location: admin_users_path)
      end
    rescue => e
      flash.now[:alert] = e.message
      render :edit
    end

    # PUT /users/1/update_profile
    def update_profile
      @user_profile = UserProfile.find_by(user_id: params[:id])
      ActiveRecord::Base.transaction do
        @user_profile.skip_submitted_notify = true
        p = update_profile_permit_params
        p[:birthday_updated_at] = p[:birthday] if @user_profile.birthday != Time.parse(p[:birthday])
        @user_profile.update!(p)
        # 自由入力項目の承認処理
        @user_profile.update!(comment_status: 'accepted', job_name_status: 'accepted',
                              tweet_status: 'accepted', dream_status: 'accepted',
                              school_name_status: 'accepted', hobby_status: 'accepted')
        flash[:notice] = 'プロフィールを更新しました。'
        redirect_back(fallback_location: admin_users_path)
      end
    rescue => e
      flash.now[:alert] = e.message
      render :edit
    end

    # PUT /users/1/restore_soft_destroy
    def restore_soft_destroy
      @user.restore!
      @user.withdrawal.destroy! if @user.withdrawal
      @user.update!(withdrawal_user_email: nil, withdrawal_user_mobile_phone: nil, is_forced_withdrawal: false)
      redirect_back(fallback_location: admin_users_path)
    end

    # PUT /users/1/send_notification
    def send_notification
      if @user.notification_sent == false && @user.user_profile.sex == 'male'
        ::User.females.includes(:user_notify).each do |target|
          target.send_push_notification('user_notification_mailer.notify_female_users.push', set_user_param, id: @user.id) if target.user_notify.notification_push_notify
        end
        @user.notification_sent = true
        @user.save!
      end
      redirect_back(fallback_location: admin_users_path)
    end

    # PUT /users/1/purchase_payingmember
    def purchase_payingmember
      purchase = ::PurchasePayingmember.find(params[:purchase_payingmember_id])
      @user.grant_gender
      type = purchase.is_premium ? 'premium_charging' : 'normal_charging'
      @user.send(:apply_payment!, @user.send(:paying_term, purchase.term), type, purchase.product_id_str)
      redirect_back(fallback_location: admin_users_path)
    end

    # PUT /users/1/purchase_point
    def purchase_point
      purchase = PurchasePoint.find(params[:purchase_point_id])
      @user.grant_gender
      @user.add_point!(purchase.point)
      redirect_back(fallback_location: admin_users_path)
    end

    # PUT /users/1/add_relation_count
    def add_relation_count
      @user.add_remain_relation_count!(params[:add_relation_count].to_i)
      redirect_back(fallback_location: admin_users_path)
    end

    # PUT /users/1/toggle_search_status
    def toggle_search_status
      @user.toggle_search_status!
      redirect_back(fallback_location: admin_users_path)
    end

    private

    def set_user_param
      { name: @user.user_profile.name, age: @user.user_profile.age, address: @user.user_profile.prof_address.name }
    end

    def set_user
      @user = ::User.includes(user_profile: ::UserProfile.eager_loading_list + [:profile_images]).find(params[:id])
    end

    def set_user_matches
      @user_matches = UserMatch.matchs_related_to_user(@user)
                               .includes(user: :user_profile, target_user: :user_profile)
                               .order(message_last_updated_at: :desc)
    end

    def set_purchase_options
      @purchase_points = PurchasePoint.order(:sort_order)
      @purchase_payingmembers = PurchasePayingmember.order(:sort_order)
    end

    def set_relation_count_options
      @relation_counts = %w(100 50 30 10)
    end

    # Update StrongParameter
    def update_permit_params
      params.require(:user).permit(:email, :password, :mobile_phone)
    end

    def update_profile_permit_params
      params.require(:user_profile).permit(:name, :sex, :comment, :birthday, :prof_address_id, :height, :prof_job_id, :dream, :tweet, :blood,
                                           :school_name, :hobby, :prof_annual_income_id, :prof_drinking_habit_id, :prof_expect_support_money_id,
                                           :prof_educational_background_id, :prof_figure_id, :prof_first_date_cost_id, :prof_have_child_id,
                                           :prof_holiday_id, :prof_marriage_id, :prof_personality_id, :prof_request_until_meet_id,
                                           :prof_smoking_habit_id, :prof_birth_place_id, :job_name)
    end

    # 更新データの調整
    def adjust_update_params
      p = update_permit_params
      p.delete(:password) if p[:password].blank?
      p
    end

    def index_paginates_per
      (params[:format] && params[:format] == 'csv') ? ::User.count : PAGINATES_PER
    end
  end
end
