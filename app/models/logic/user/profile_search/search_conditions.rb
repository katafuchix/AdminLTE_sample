# 男女共通の検索条件を定義
# rubocop:disable Metrics/ModuleLength
module Logic
  module User
    module ProfileSearch
      module SearchConditions
        extend ActiveSupport::Concern

        def contents_height
          min = Settings.height.minimum
          max = Settings.height.maximum
          (min..max).map { |m| { id: m, name: "#{m}cm" } }
        end

        private

        def common_search_master_conditions
          conditions = []
          COMMON_SEARCH_MASTERS.each do |master|
            name = master[:cls].name.underscore
            conditions << {
              key: "#{user_profile_search_key_prefix}_#{name.gsub('master/', 'prof_')}_id_in",
              name: I18n.t(name, scope: 'activerecord.models'), contents: master[:cls].contents,
              input_type: INPUT_TYPE[:multiple], condition_sort_order: master[:condition_sort_order]
            }
          end
          conditions
        end

        def address_condition
          { key: "#{user_profile_search_key_prefix}_prof_address_id_in", name: I18n.t('activerecord.models.master/address'),
            contents: ::Master::Prefecture.contents,
            input_type: INPUT_TYPE[:multiple], condition_sort_order: 2 }
        end

        def birth_place_condition
          { key: "#{user_profile_search_key_prefix}_prof_birth_place_id_in",
            name: I18n.t('activerecord.models.master/birth_place'),
            contents: ::Master::Prefecture.contents,
            input_type: INPUT_TYPE[:multiple], condition_sort_order: 14 }
        end

        def blood_condition
          { key: "#{user_profile_search_key_prefix}_blood_in", name: I18n.t('search.name.blood'),
            contents: ::UserProfile.blood_search_contents,
            input_type: INPUT_TYPE[:multiple], condition_sort_order: 10 }
        end

        def comment_present_condition
          { key: "#{user_profile_search_key_prefix}_comment_present", name: I18n.t('search.name.comment'),
            contents: contents_present_or_blank, input_type: INPUT_TYPE[:select],
            condition_sort_order: 3 }
        end

        def profimages_present_condition
          { key: 'profile_images_count_present', name: I18n.t('search.name.profile_image'),
            contents: contents_present_or_blank, input_type: INPUT_TYPE[:select],
            condition_sort_order: 4 }
        end

        def age_condition
          { key: 'age_range', name: I18n.t('search.name.age'),
            contents: contents_age, input_type: INPUT_TYPE[:select_range], condition_sort_order: 1 }
        end

        def height_condition
          { key: 'user_profile_height_in', name: I18n.t('search.name.height'), contents: contents_height,
            input_type: INPUT_TYPE[:select_range], condition_sort_order: 5 }
        end

        def login_date_condition
          { key: 'login_date_range', name: I18n.t('search.name.last_login_date'),
            contents: contents_login_condition, input_type: INPUT_TYPE[:select],
            condition_sort_order: 18 }
        end

        def just_started_condition
          { key: 'just_started_true', name: I18n.t('search.name.just_started', day: 3),
            contents: contents_yes_or_no,
            input_type: INPUT_TYPE[:select], condition_sort_order: 19 }
        end

        def order_condition
          { key: 'sorts', name: I18n.t('search.name.sort'),
            contents: contents_order_by, input_type: INPUT_TYPE[:select], condition_sort_order: 20 }
        end

        def popular_condition
          { key: 'popular_true', name: I18n.t('search.name.popular'),
            contents: contents_yes_or_no, input_type: INPUT_TYPE[:select], condition_sort_order: 21 }
        end

        def like_message_condition
          { key: 'like_message_true', name: I18n.t('search.name.like_message'),
            contents: contents_yes_or_no, input_type: INPUT_TYPE[:select], condition_sort_order: 22 }
        end

        def common_type_condition
          { key: 'common_type_true', name: I18n.t('search.name.common_type'),
            contents: contents_present_or_blank, input_type: INPUT_TYPE[:select], condition_sort_order: 23 }
        end

        def freeword_condition
          { key: 'freeword_cont', name: I18n.t('search.name.free_word'),
            input_type: INPUT_TYPE[:input], condition_sort_order: 27 }
        end

        def good_place_present_condition
          { key: "#{user_profile_search_key_prefix}_good_place_present", name: I18n.t('search.name.good_place'),
            contents: contents_present_or_blank, input_type: INPUT_TYPE[:select],
            condition_sort_order: 28 }
        end

        def date_place_present_condition
          { key: "#{user_profile_search_key_prefix}_date_place_present", name: I18n.t('search.name.date_place'),
            contents: contents_present_or_blank, input_type: INPUT_TYPE[:select],
            condition_sort_order: 29 }
        end

        def personality_list_condition
          { key: 'personality_list_id_in', name: I18n.t('search.name.personality_list'),
            contents: Master::Personality.all.map { |m| m.slice(:id, :name, :enabled, :sort_order) }, input_type: INPUT_TYPE[:multiple],
            condition_sort_order: 30 }
        end

        def meet_at_today_lunch_condition
          { key: "#{user_profile_search_key_prefix}_meet_at_today_lunch_present", name: I18n.t('search.name.meet_at_today_lunch'),
            contents: contents_yes_or_no, input_type: INPUT_TYPE[:select], condition_sort_order: 31 }
        end

        def meet_at_today_tea_condition
          { key: "#{user_profile_search_key_prefix}_meet_at_today_tea_present", name: I18n.t('search.name.meet_at_today_tea'),
            contents: contents_yes_or_no, input_type: INPUT_TYPE[:select], condition_sort_order: 32 }
        end

        def meet_at_today_dinner_condition
          { key: "#{user_profile_search_key_prefix}_meet_at_today_dinner_present", name: I18n.t('search.name.meet_at_today_dinner'),
            contents: contents_yes_or_no, input_type: INPUT_TYPE[:select], condition_sort_order: 33 }
        end

        def user_profile_search_key_prefix
          ::UserProfile.name.underscore
        end

        def contents_present_or_blank
          [{ id: 1, name: I18n.t('search.type.present') }, { id: 0, name: I18n.t('search.type.blank') }]
        end

        def contents_yes_or_no
          [{ id: 1, name: I18n.t('search.type.type_yes') }, { id: 0, name: I18n.t('search.type.type_no') }]
        end

        def contents_order_by
          [{ id: 'users.id ASC', name: I18n.t('search.order_by.user_id_asc') },
           { id: 'users.id DESC', name: I18n.t('search.order_by.user_id_desc') },
           { id: 'users.last_sign_in_at ASC', name: I18n.t('search.order_by.user_last_login_asc') },
           { id: 'users.last_sign_in_at DESC', name: I18n.t('search.order_by.user_last_login_desc') },
           { id: 'CAST(user_profiles.name AS CHAR) ASC', name: I18n.t('search.order_by.user_name_asc') },
           { id: 'CAST(user_profiles.name AS CHAR) DESC', name: I18n.t('search.order_by.user_name_desc') },
           { id: 'users.remain_relation_count ASC', name: I18n.t('search.order_by.user_remaining_point_asc') },
           { id: 'users.remain_relation_count DESC', name: I18n.t('search.order_by.user_remaining_point_desc') },
           { id: '(users.incomming_visitors_count + users.incomming_relations_count) ASC', name: I18n.t('search.order_by.user_total_popular_count_asc') },
           { id: '(users.incomming_visitors_count + users.incomming_relations_count) DESC', name: I18n.t('search.order_by.user_total_popular_count_desc') }]
        end

        def contents_age
          min = Settings.age.minimum
          max = Settings.age.maximum
          (min..max).map { |m| { id: m, name: "#{m}歳" } }
        end

        def contents_login_condition
          [{ id: 1, name: I18n.t('search.last_login.online') },
           { id: 2, name: I18n.t('search.last_login.in_24h') },
           { id: 3, name: I18n.t('search.last_login.in_3days') },
           { id: 4, name: I18n.t('search.last_login.in_1week') },
           { id: 5, name: I18n.t('search.last_login.in_2weeks') },
           { id: 6, name: I18n.t('search.last_login.in_1month') },
           { id: 7, name: I18n.t('search.last_login.out_1month') }]
        end

        def popular_member_condition
          { key: 'popular_member_true', name: I18n.t('search.name.popular_member'),
            contents: contents_yes_or_no, input_type: INPUT_TYPE[:select], condition_sort_order: 24 }
        end
      end
    end
  end
end
