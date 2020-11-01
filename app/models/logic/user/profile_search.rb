# 検索条件を定義
# 男女別
module Logic
  module User
    module ProfileSearch
      extend ActiveSupport::Concern
      include SearchConditions

      INPUT_TYPE = { select: 0, input: 1, select_range: 2, multiple: 3 }.freeze
      COMMON_SEARCH_MASTERS = [
        { cls: ::Master::DrinkingHabit, condition_sort_order: 8 },
        { cls: ::Master::Figure, condition_sort_order: 6 },
        { cls: ::Master::HaveChild, condition_sort_order: 17 },
        { cls: ::Master::Holiday, condition_sort_order: 15 },
        { cls: ::Master::Marriage, condition_sort_order: 16 },
        { cls: ::Master::RequestUntilMeet, condition_sort_order: 9 },
        { cls: ::Master::SmokingHabit, condition_sort_order: 7 },
        { cls: ::Master::Job, condition_sort_order: 12 },
        { cls: ::Master::EducationalBackground, condition_sort_order: 13 }
      ].freeze

      # 検索条件を取得
      # @return [Array] 検索条件一覧
      def profile_search_conditions(premium_charging_member = false)
        conditions = common_conditions
        conditions = conditions.concat(premium_conditions) if premium_charging_member || premium_charging_member?
        conditions.sort do |a, b|
          a[:condition_sort_order] <=> b[:condition_sort_order]
        end
      end

      # 検索条件一覧
      # @return [Array] 検索条件一覧
      def common_conditions
        conditions = [address_condition, birth_place_condition,
                      blood_condition, comment_present_condition,
                      good_place_present_condition, date_place_present_condition,
                      profimages_present_condition, login_date_condition,
                      just_started_condition, age_condition, height_condition, popular_member_condition,
                      personality_list_condition, meet_at_today_lunch_condition, meet_at_today_tea_condition, meet_at_today_dinner_condition]
        conditions.concat(common_search_master_conditions)
      end

      # プレミアム会員のみの検索項目
      # @return [Array] 検索条件一覧
      def premium_conditions
        [order_condition, popular_condition, like_message_condition]
      end
    end
  end
end
