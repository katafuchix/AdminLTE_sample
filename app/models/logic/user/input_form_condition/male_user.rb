# 男性のプロフィール入力項目
module Logic
  module User
    module InputFormCondition
      module MaleUser
        extend ActiveSupport::Concern

        # rubocop:disable all

        # 入力画面の入力を許可するパラメータを取得
        # @return [Array] パラメータ一覧
        def user_profile_permit_params_create
          [:comment, :good_place, :date_place, :prof_address_id, :prof_job_id, :prof_annual_income_id,
           :icon, :prof_request_until_meet_id, :tweet, :background_image]
        end

        # 入力画面の入力を許可するパラメータを取得
        # @return [Array] パラメータ一覧
        def user_profile_permit_params_update
          [:comment, :good_place, :date_place, :name, :blood,
           :prof_expect_support_money_id, :prof_first_date_cost_id,
           :prof_address_id, :prof_job_id, :prof_educational_background_id, :height, :prof_figure_id,
           :prof_smoking_habit_id, :prof_drinking_habit_id, :prof_birth_place_id,
           :prof_annual_income_id, :prof_holiday_id, :prof_marriage_id, :prof_have_child_id, :school_name,
           :job_name, :hobby, :icon, :prof_personality_id, :prof_request_until_meet_id, :tweet, :background_image]
        end

        # プロフィール入力画面の状態を返却
        # @return [Hash] 入力画面状態
        def input_form_condition_create
          {
            comment: ::UserProfile::INPUT_FORM_CONDITION_TYPE['optional'],
            good_place: ::UserProfile::INPUT_FORM_CONDITION_TYPE['optional'],
            date_place: ::UserProfile::INPUT_FORM_CONDITION_TYPE['optional'],
            name: ::UserProfile::INPUT_FORM_CONDITION_TYPE['disabled'],
            icon: ::UserProfile::INPUT_FORM_CONDITION_TYPE['optional'],
            birthday: ::UserProfile::INPUT_FORM_CONDITION_TYPE['disabled'],
            blood_id: ::UserProfile::INPUT_FORM_CONDITION_TYPE['hidden'],
            dream: ::UserProfile::INPUT_FORM_CONDITION_TYPE['hidden'],
            prof_expect_support_money_id: ::UserProfile::INPUT_FORM_CONDITION_TYPE['hidden'],
            prof_first_date_cost_id: ::UserProfile::INPUT_FORM_CONDITION_TYPE['hidden'],
            prof_address_id: ::UserProfile::INPUT_FORM_CONDITION_TYPE['required'],
            prof_job_id: ::UserProfile::INPUT_FORM_CONDITION_TYPE['optional'],
            prof_educational_background_id: ::UserProfile::INPUT_FORM_CONDITION_TYPE['hidden'],
            height: ::UserProfile::INPUT_FORM_CONDITION_TYPE['hidden'],
            prof_figure_id: ::UserProfile::INPUT_FORM_CONDITION_TYPE['hidden'],
            prof_smoking_habit_id: ::UserProfile::INPUT_FORM_CONDITION_TYPE['hidden'],
            prof_drinking_habit_id: ::UserProfile::INPUT_FORM_CONDITION_TYPE['hidden'],
            prof_birth_place_id: ::UserProfile::INPUT_FORM_CONDITION_TYPE['hidden'],
            prof_annual_income_id: ::UserProfile::INPUT_FORM_CONDITION_TYPE['optional'],
            prof_holiday_id: ::UserProfile::INPUT_FORM_CONDITION_TYPE['hidden'],
            prof_marriage_id: ::UserProfile::INPUT_FORM_CONDITION_TYPE['hidden'],
            prof_have_child_id: ::UserProfile::INPUT_FORM_CONDITION_TYPE['hidden'],
            school_name: ::UserProfile::INPUT_FORM_CONDITION_TYPE['hidden'],
            job_name: ::UserProfile::INPUT_FORM_CONDITION_TYPE['hidden'],
            hobby: ::UserProfile::INPUT_FORM_CONDITION_TYPE['hidden'],
            prof_personality_id: ::UserProfile::INPUT_FORM_CONDITION_TYPE['hidden'],
            prof_request_until_meet_id: ::UserProfile::INPUT_FORM_CONDITION_TYPE['hidden'],
            tweet: ::UserProfile::INPUT_FORM_CONDITION_TYPE['optional'],
            background_image: ::UserProfile::INPUT_FORM_CONDITION_TYPE['optional'],
          }
        end

        # プロフィール入力画面の状態を返却
        # @return [Hash] 入力画面状態
        def input_form_condition_update
          {
            comment: ::UserProfile::INPUT_FORM_CONDITION_TYPE['optional'],
            good_place: ::UserProfile::INPUT_FORM_CONDITION_TYPE['optional'],
            date_place: ::UserProfile::INPUT_FORM_CONDITION_TYPE['optional'],
            name: ::UserProfile::INPUT_FORM_CONDITION_TYPE['optional'],
            icon: ::UserProfile::INPUT_FORM_CONDITION_TYPE['optional'],
            birthday: ::UserProfile::INPUT_FORM_CONDITION_TYPE['disabled'],
            blood_id: ::UserProfile::INPUT_FORM_CONDITION_TYPE['optional'],
            dream: ::UserProfile::INPUT_FORM_CONDITION_TYPE['hidden'],
            prof_expect_support_money_id: ::UserProfile::INPUT_FORM_CONDITION_TYPE['optional'],
            prof_first_date_cost_id: ::UserProfile::INPUT_FORM_CONDITION_TYPE['optional'],
            prof_address_id: ::UserProfile::INPUT_FORM_CONDITION_TYPE['optional'],
            prof_job_id: ::UserProfile::INPUT_FORM_CONDITION_TYPE['optional'],
            prof_educational_background_id: ::UserProfile::INPUT_FORM_CONDITION_TYPE['optional'],
            height: ::UserProfile::INPUT_FORM_CONDITION_TYPE['optional'],
            prof_figure_id: ::UserProfile::INPUT_FORM_CONDITION_TYPE['optional'],
            prof_smoking_habit_id: ::UserProfile::INPUT_FORM_CONDITION_TYPE['optional'],
            prof_drinking_habit_id: ::UserProfile::INPUT_FORM_CONDITION_TYPE['optional'],
            prof_birth_place_id: ::UserProfile::INPUT_FORM_CONDITION_TYPE['optional'],
            prof_annual_income_id: ::UserProfile::INPUT_FORM_CONDITION_TYPE['optional'],
            prof_holiday_id: ::UserProfile::INPUT_FORM_CONDITION_TYPE['optional'],
            prof_marriage_id: ::UserProfile::INPUT_FORM_CONDITION_TYPE['optional'],
            prof_have_child_id: ::UserProfile::INPUT_FORM_CONDITION_TYPE['optional'],
            school_name: ::UserProfile::INPUT_FORM_CONDITION_TYPE['optional'],
            job_name: ::UserProfile::INPUT_FORM_CONDITION_TYPE['optional'],
            hobby: ::UserProfile::INPUT_FORM_CONDITION_TYPE['optional'],
            prof_personality_id: ::UserProfile::INPUT_FORM_CONDITION_TYPE['optional'],
            prof_request_until_meet_id: ::UserProfile::INPUT_FORM_CONDITION_TYPE['optional'],
            tweet: ::UserProfile::INPUT_FORM_CONDITION_TYPE['optional'],
            background_image: ::UserProfile::INPUT_FORM_CONDITION_TYPE['optional'],
          }
        end

        # rubocop:enable all
      end
    end
  end
end
