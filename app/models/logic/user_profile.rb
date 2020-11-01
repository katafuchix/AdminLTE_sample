# frozen_string_literal: true
module Logic
  module UserProfile
    extend ActiveSupport::Concern

    included do
      include Logic::UserProfile::ProfileImage

      EDIT_TYPE = %(create update).freeze
      INPUT_FORM_CONDITION_TYPE = %(required optional disabled hidden).freeze

      START_SIGN_MAP = [
        { name: 'Capricorn', borderValue: 119 }, { name: 'Aquarius', borderValue: 218 },
        { name: 'Pisces', borderValue: 320 }, { name: 'Aries', borderValue: 419 },
        { name: 'Taurus', borderValue: 520 }, { name: 'Gemini', borderValue: 621 },
        { name: 'Cancer', borderValue: 722 }, { name: 'Leo', borderValue: 822 },
        { name: 'Virgo', borderValue: 922 }, { name: 'Libra', borderValue: 1023 },
        { name: 'Scorpio', borderValue: 1122 }, { name: 'Sagittarius', borderValue: 1221 }
      ].freeze

      EAGER_LOADING_LIST = [
        :prof_address, :prof_birth_place, :prof_job, :prof_annual_income,
        :prof_drinking_habit, :prof_educational_background,
        :prof_expect_support_money, :prof_figure, :prof_first_date_cost,
        :prof_have_child, :prof_holiday, :prof_marriage, :prof_personality,
        :prof_request_until_meet, :prof_smoking_habit, :profile_images, :taggings
      ].freeze
    end

    class_methods do
      # 血液型を検索条件のhashに変換
      # @return [Integer] ユーザの年齢
      def blood_search_contents
        ret = []
        ::UserProfile.bloods.each_with_index do |obj, index|
          ret << { id: obj.last, name: obj.first.to_s.upcase, sort_order: index }
        end
        ret
      end

      def ransackable_attributes(_auth_object = nil)
        %w(sex comment blood dream prof_expect_support_money_id prof_first_date_cost_id prof_address_id \
           prof_job_id prof_educational_background_id height prof_figure_id prof_smoking_habit_id \
           prof_drinking_habit_id prof_birth_place_id prof_annual_income_id prof_holiday_id \
           prof_request_until_meet_id prof_marriage_id prof_have_child_id school_name hobby job_name icon \
           comment_was_accepted school_name_was_accepted hobby_was_accepted job_name_was_accepted \
           tweet_was_accepted good_place_was_accepted dream_was_accepted)
      end

      def eager_loading_list
        list = EAGER_LOADING_LIST.dup.clone
        list.delete(:profile_images)
        list << { profile_images: { user_profile: [:user, :profile_images] } }
        list
      end

      # 未承認のプロフィール項目数
      # @return [Hash] { xx_count: num }
      def pending_status_count
        Rails.cache.fetch("UserProfile#pending_status_count:updated_at:#{maximum(:updated_at)}", expires_in: 1.day) do
          query = proc { |m| "count(case when #{m}_status = 0 and #{m} is not null then 1 else null end) as #{m}_count" }
          result = select(approvable_columns.map { |m| query.call(m) }.join(', '))[0]
          approvable_columns.map { |m| "#{m}_count" }.each_with_object({}) do |count_name, h|
            h[count_name] = result.public_send(count_name)
          end
        end
      end
    end

    # rubocop:disable all
    # 変数のEnumをI18nに、外部キーを名前に変換
    # アイコンをUTF-8にエンコード
    # @param [Hash] arg パラメータ
    # @return [Hash] 変換後のインスタンス変数
    def actual_values(**arg)
      {
        user_id: user_id, name: name,
        sex: sex_i18n,
        sex_enum: sex,
        age_confirmed_at: age_confirmed_at,
        income_confirmed_at: income_confirmed_at,
        birthday: birthday.try(:to_date),
        age: try(:age),
        prof_address: prof_address.try(:name),
        prof_birth_place: prof_birth_place.try(:name),
        height: height, prof_job: prof_job.try(:name),
        blood: blood_i18n, icon: main_image_url(**arg),
        prof_annual_income: prof_annual_income.try(:name),
        prof_drinking_habit: prof_drinking_habit.try(:name),
        prof_expect_support_money: prof_expect_support_money.try(:name),
        prof_figure: prof_figure.try(:name),
        prof_first_date_cost: prof_first_date_cost.try(:name),
        prof_have_child: prof_have_child.try(:name),
        prof_holiday: prof_holiday.try(:name),
        prof_marriage: prof_marriage.try(:name),
        personality_list: ::Rails.cache.fetch("UserProfile#actual_values:#{user_id}", expires_in: 1.day, force: true) do
                            ::Master::Personality.where(id: personality_list).pluck(:name)
                          end,
        prof_request_until_meet: prof_request_until_meet.try(:name),
        prof_smoking_habit: prof_smoking_habit.try(:name),
        prof_educational_background: prof_educational_background.try(:name),
        dream: dream, school_name: school_name,
        job_name: job_name, hobby: hobby,
        #just_started: user.just_started?,
        #popular: user.popular?,
        #like_message: user.like_message?,
        #common_type: user.common_type?,
        #online: user.online?,
        tweet: tweet.presence || I18n.t('user_profile.default_tweet')#,
        #background_image: background_image_url,
        #meet_at_today_lunch: meet_at_today_lunch,
        #meet_at_today_tea: meet_at_today_tea,
        #meet_at_today_dinner: meet_at_today_dinner,
      }.merge(approval_values).with_indifferent_access
    end
    # rubocop:enable all

    # プロフィールの更新を行う
    # @param [Hash] params APIリクエストパラメータ
    # @raise バリデーションエラー
    def update_by_request!(params)
      update!(update_params(params))
    end

    # プロフィールの生年月日のみ更新する
    # @param [Hash] params APIリクエストパラメータ
    # @raise バリデーションエラー
    # 年齢確認前かつ１回も生年月日を更新していない時に更新できる
    def update_birthday_only_once!(params)
      fail StandardError, I18n.t('activerecord.errors.messages.birthday.already_updated') unless birthday_updated_at.blank?
      fail StandardError, I18n.t('activerecord.errors.messages.birthday.need_before_age_confirmed') if user.checked_age_confirmation?
      update!(params.slice(:birthday).merge(birthday_updated_at: Time.current))
    end

    # 異性のEnumのvalueを取得
    # @return [Integer] EnumのInt値(male:0 female:1)
    def other_sex
      (::UserProfile.sexes[sex.to_sym] + 1) % 2
    end

    # 年齢
    # @return [Integer] ユーザの年齢
    def age
      return nil if birthday.blank?
      birth = birthday.strftime('%Y%m%d').to_i
      now = Time.current.strftime('%Y%m%d').to_i
      (now - birth) / 10_000
    end

    # アイコン(メイン画像から取得)
    def icon_by_main_image
      return nil if profile_images.blank?
      return nil if user.deleted_at.present?
      main_image = profile_images.find { |s| s.image_status == 'accepted' }.try(:image)
      main_image ||= profile_images.find { |s| s.image_was_accepted.try(:url).present? }.try(:image_was_accepted)
      main_image
    end

    # サブ画像を公開するか
    # それ以外 -> 公開範囲チェックあり
    # @param [Hash] arg パラメータ
    # @return [Boolean] 公開するか
    def public_sub_image?(profile_image, **arg)
      return false if profile_image.blank?
      browse_user = arg[:browse_user]
      if browse_user.present?
        if profile_image.image_role == 'relation_user_only' &&
           !browse_user.incomming_active_relation_users.detect { |u| u.id == user.id }
          return false
        elsif profile_image.image_role == 'matching_user_only' &&
              !browse_user.incomming_matched_relation_users.detect { |u| u.id == user.id }
          return false
        elsif profile_image.image_role == 'show_private'
          return false
        end
      end
      true
    end

    # メイン画像URL
    # @param [Hash] arg パラメータ
    def main_image_url(**_arg)
      icon_by_main_image.try(:url) || default_icon_url
    end

    # サブ画像URL
    # @param [String] url 画像URL
    # @param [Hash] arg パラメータ
    def sub_image_url(profile_image, target, **arg)
      return default_icon_url unless public_sub_image?(profile_image, arg)
      profile_image.was_accepted(target).try(:url) || default_icon_url
    end

    def default_icon_url
      if sex == 'male'
        icon_name = 'male'
        #if user.premium_charging_member?
        #  icon_name = 'male_premium_charging'
        #elsif user.normal_charging_member?
        #  icon_name = 'male_normal_charging'
        #end
      else
        icon_name = 'female'
      end
      ActionController::Base.helpers.asset_url("user_profile_default_icon/#{icon_name}.png", host: Settings.app.url)
    end

    # アソシエーションで取得したprofile_imagesのメイン画像かどうか判定する
    def check_main_image?(profile_image)
      return false if profile_image.blank?
      main_image_id = profile_images.first.id
      profile_image.id == main_image_id
    end

    private

    def update_params(params)
      params = adjust_blood(params)
      params.slice(*user.user_profile_permit_params).to_h
    end

    def adjust_blood(params)
      if params[:blood_id]
        params[:blood] = ::UserProfile.bloods.key(params[:blood_id].to_i)
        fail StandardError, I18n.t('api.errors.invalid_blood_id') if params[:blood].blank?
      end
      params
    end
  end
end
