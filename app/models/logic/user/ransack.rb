# ransack scopeを定義
# パラメータをransack用にパースする
# rubocop:disable Metrics/ModuleLength
module Logic
  module User
    module Ransack
      extend ActiveSupport::Concern

      MEET_AT_TODAY_TYPE = { lunch: 0, tea: 1, dinner: 2 }.freeze

      included do
        scope :age_gteq, lambda { |age = 18|
          birthday = Time.current.years_ago(age.to_i).days_ago(1).end_of_day
          joins(:user_profile).where(::UserProfile.arel_table[:birthday].lteq(birthday))
        }
        scope :age_lteq, lambda { |age = 100|
          birthday = Time.current.years_ago(age.to_i + 1).beginning_of_day
          joins(:user_profile).where(::UserProfile.arel_table[:birthday].gteq(birthday))
        }
        scope :age_range, lambda { |age|
          if age
            ages = age.split('..')
            age_gteq(ages[0]).age_lteq(ages[1])
          end
        }
        scope :online_true, lambda {
          where(arel_table[:current_sign_in_at].gteq(Time.current - Settings.online_minutes.minutes))
        }
        scope :order_desc, ->(name) { order(name => :desc) }
        scope :just_started_true, lambda {
          where('users.created_at >= ?', Time.current - 3.days)
        }
        scope :login_date_range, lambda { |type = 1|
          case type.to_i
          when 1 then online_true
          when 2 then where('users.current_sign_in_at >= ?', Time.current - 1.days)
          when 3 then where('users.current_sign_in_at >= ?', Time.current - 3.days)
          when 4 then where('users.current_sign_in_at >= ?', Time.current - 7.days)
          when 5 then where('users.current_sign_in_at >= ?', Time.current - 14.days)
          when 6 then where('users.current_sign_in_at >= ?', Time.current - 30.days)
          when 7 then where('users.current_sign_in_at IS NOT NULL')
          end
        }
        scope :popular_member_true, lambda {
          where('(users.incomming_visitors_count + users.incomming_relations_count) >= ?', Settings.popular_minimum)
        }
        scope :profile_image, lambda { |icon = 1|
          ids = ::ProfileImage.have_images
          case icon.to_i
          when 1 then joins(:user_profile).where('user_profiles.id NOT IN(?)', ids)
          when 2 then joins(:user_profile).where('user_profiles.id IN(?)', ids)
          end
        }
        scope :profile_sub_image, lambda { |icon = 1|
          ids = ::ProfileImage.have_sub_images
          case icon.to_i
          when 1 then joins(:user_profile).where('user_profiles.id NOT IN(?)', ids)
          when 2 then joins(:user_profile).where('user_profiles.id IN(?)', ids)
          end
        }
        scope :profile_comment, lambda { |comment = 1|
          case comment.to_i
          when 1 then joins(:user_profile).where("user_profiles.comment_was_accepted is NULL OR user_profiles.comment_was_accepted = ''")
          when 2 then joins(:user_profile).where("user_profiles.comment_was_accepted is NOT NULL AND user_profiles.comment_was_accepted <> ''")
          end
        }
        scope :profile_good_place, lambda { |good_place = 1|
          case good_place.to_i
          when 1 then joins(:user_profile).where("user_profiles.good_place_was_accepted is NULL OR user_profiles.good_place_was_accepted = ''")
          when 2 then joins(:user_profile).where("user_profiles.good_place_was_accepted is NOT NULL AND user_profiles.good_place_was_accepted <> ''")
          end
        }
        scope :profile_date_place, lambda { |date_place = 1|
          case date_place.to_i
          when 1 then joins(:user_profile).where("user_profiles.date_place_was_accepted is NULL OR user_profiles.date_place_was_accepted = ''")
          when 2 then joins(:user_profile).where("user_profiles.date_place_was_accepted is NOT NULL AND user_profiles.date_place_was_accepted <> ''")
          end
        }
        scope :personality_list_id_in, lambda { |*personality_ids|
          return unless personality_ids.present?
          joins(:user_profile).merge(::UserProfile.tagged_with(personality_ids, on: :personality, any: true))
        }
        scope :profile_meet_at_today, lambda { |*meet_at_today|
          # meet_at_today_ransack_paramメソッドで0と1を設定すると、
          # meet_at_todayにはfalseとtrueに変換された値が設定される
          sql = []
          sql << "user_profiles.meet_at_today_lunch = 1" if meet_at_today[MEET_AT_TODAY_TYPE[:lunch]]
          sql << "user_profiles.meet_at_today_tea = 1" if meet_at_today[MEET_AT_TODAY_TYPE[:tea]]
          sql << "user_profiles.meet_at_today_dinner = 1" if meet_at_today[MEET_AT_TODAY_TYPE[:dinner]]
          joins(:user_profile).where(sql.join(' OR ').to_s)
        }
        scope :profile_hobby, lambda { |hobby = 1|
          case hobby.to_i
          when 1 then joins(:user_profile).where("user_profiles.hobby_was_accepted is NULL OR user_profiles.hobby_was_accepted = ''")
          when 2 then joins(:user_profile).where("user_profiles.hobby_was_accepted is NOT NULL AND user_profiles.hobby_was_accepted <> ''")
          end
        }
        scope :profile_dream, lambda { |dream = 1|
          case dream.to_i
          when 1 then joins(:user_profile).where("user_profiles.dream_was_accepted is NULL OR user_profiles.dream_was_accepted = ''")
          when 2 then joins(:user_profile).where("user_profiles.dream_was_accepted is NOT NULL AND user_profiles.dream_was_accepted <> ''")
          end
        }
        scope :premium_member_true, lambda {
          user_ids = ::UserPayment.where('enabled = 1 AND start_at <= :current AND :current <= end_at AND payment_type = 1', current: Time.current.to_s).pluck(:user_id)
          where('users.id IN (?)', user_ids)
        }
      end

      class_methods do
        def ransackable_scopes(_auth_object = nil)
          %i(age_gteq age_lteq online_true order_desc just_started_true age_range login_date_range popular_member_true profile_image profile_comment
             profile_good_place profile_date_place personality_list_id_in profile_meet_at_today profile_sub_image profile_hobby profile_dream premium_member_true)
        end

        def ransackable_attributes(_auth_object = nil)
          %w(profile_images_count current_sign_in_at created_at incomming_relations_count)
        end
      end

      # Ransack用にパラメータを調整
      # @return [Hash] 調整後パラメータ
      def adjust_ransack_param(param, admin = false)
        p = param.except(:auth_token, :page)
        p = comma_string_ransack_param(p)
        p = sex_ransack_param(p) unless admin
        p = date_ransack_param(p)
        p = range_ransack_param(p)
        p = profile_image_ransack_param(p)
        p = profile_sub_image_ransack_param(p)
        p = comment_ransack_param(p)
        p = good_place_ransack_param(p)
        p = date_place_ransack_param(p)
        p = meet_at_today_ransack_param(p)
        p = hobby_ransack_param(p)
        p = dream_ransack_param(p)
        p = reject_ransack_param(p) unless admin
        p = freeword_ransack_param(p)
        p
      end

      # プレミアム会員取得Ransack用にパラメータを調整
      def adjust_ransack_param_premium(param)
        p = adjust_ransack_param(param)
        p = premium_user_ransack_param(p)
        p
      end

      # ユーザーが検索不能なパラメータ
      # @abstract
      # @return [Array] パラメータ一覧
      def reject_ransack_keys
        []
      end

      # プレミアムのみ検索可能なパラメータ
      # @return [Array] パラメータ一覧
      def premium_ransack_keys
        [:sorts, :popular_true, :like_message_true]
      end

      private

      # カンマ区切りで複数検索に対応
      def comma_string_ransack_param(param)
        arr = []
        param.each do |k, v|
          arr << (v && !v.is_a?(Array) && k.end_with?('_in') ? [k, v.split(',')] : [k, v])
        end
        arr.to_h.with_indifferent_access
      end

      def sex_ransack_param(param)
        param[:user_profile_sex_eq] = user_profile.other_sex
        param
      end

      def date_ransack_param(param)
        if param[:current_sign_in_at_gteq].present?
          param[:current_sign_in_at_gteq] = param[:current_sign_in_at_gteq].strftime('%Y-%m-%d')
        end
        param
      end

      def range_ransack_param(param)
        height_in = param[:user_profile_height_in]
        return param if height_in.blank?
        height_in = height_in.first if height_in.is_a?(Array)
        heights = height_in.split('..').map(&:to_i)
        param[:user_profile_height_in] = (heights[0]..heights[1])
        param
      end

      def profile_image_ransack_param(param)
        if param[:profile_images_count_present].present?
          if param[:profile_images_count_present].to_i.zero?
            param[:profile_images_count_eq] = 0
            param[:profile_image] = 1
          else
            param[:profile_images_count_gt] = 0
            param[:profile_image] = 2
          end
          param.delete(:profile_images_count_present)
        end
        param
      end

      def profile_sub_image_ransack_param(param)
        if param[:profile_sub_images_count_present].present?
          param[:profile_sub_image] = if param[:profile_sub_images_count_present].to_i.zero?
                                        1
                                      else
                                        2
                                      end
          param.delete(:profile_sub_images_count_present)
        end
        param
      end

      def comment_ransack_param(param)
        if param[:user_profile_comment_present].present?
          param[:profile_comment] = if param[:user_profile_comment_present].to_i.zero?
                                      1
                                    else
                                      2
                                    end
          param.delete(:user_profile_comment_present)
        end
        param
      end

      def good_place_ransack_param(param)
        if param[:user_profile_good_place_present].present?
          param[:profile_good_place] = if param[:user_profile_good_place_present].to_i.zero?
                                         1
                                       else
                                         2
                                       end
          param.delete(:user_profile_good_place_present)
        end
        param
      end

      def date_place_ransack_param(param)
        if param[:user_profile_date_place_present].present?
          param[:profile_date_place] = if param[:user_profile_date_place_present].to_i.zero?
                                         1
                                       else
                                         2
                                       end
          param.delete(:user_profile_date_place_present)
        end
        param
      end

      def meet_at_today_ransack_param(param)
        param[:profile_meet_at_today] = []
        param = meet_at_today_lunch_ransack_param(param)
        param = meet_at_today_tea_ransack_param(param)
        param = meet_at_today_dinner_ransack_param(param)
        param
      end

      def meet_at_today_lunch_ransack_param(param)
        # 初期値:ランチ未設定
        param[:profile_meet_at_today][MEET_AT_TODAY_TYPE[:lunch]] = 0
        if param[:user_profile_meet_at_today_lunch_present].present?
          unless param[:user_profile_meet_at_today_lunch_present].to_i.zero?
            param[:profile_meet_at_today][MEET_AT_TODAY_TYPE[:lunch]] = 1
          end
          param.delete(:user_profile_meet_at_today_lunch_present)
        end
        param
      end

      def meet_at_today_tea_ransack_param(param)
        # 初期値:お茶未設定
        param[:profile_meet_at_today][MEET_AT_TODAY_TYPE[:tea]] = 0
        if param[:user_profile_meet_at_today_tea_present].present?
          unless param[:user_profile_meet_at_today_tea_present].to_i.zero?
            param[:profile_meet_at_today][MEET_AT_TODAY_TYPE[:tea]] = 1
          end
          param.delete(:user_profile_meet_at_today_tea_present)
        end
        param
      end

      def meet_at_today_dinner_ransack_param(param)
        # 初期値:ディナー未設定
        param[:profile_meet_at_today][MEET_AT_TODAY_TYPE[:dinner]] = 0
        if param[:user_profile_meet_at_today_dinner_present].present?
          unless param[:user_profile_meet_at_today_dinner_present].to_i.zero?
            param[:profile_meet_at_today][MEET_AT_TODAY_TYPE[:dinner]] = 1
          end
          param.delete(:user_profile_meet_at_today_dinner_present)
        end
        param
      end

      def hobby_ransack_param(param)
        if param[:user_profile_hobby_present].present?
          param[:profile_hobby] = if param[:user_profile_hobby_present].to_i.zero?
                                    1
                                  else
                                    2
                                  end
          param.delete(:user_profile_hobby_present)
        end
        param
      end

      def dream_ransack_param(param)
        if param[:user_profile_dream_present].present?
          param[:profile_dream] = if param[:user_profile_dream_present].to_i.zero?
                                    1
                                  else
                                    2
                                  end
          param.delete(:user_profile_dream_present)
        end
        param
      end

      # 検索不能なパラメータを削除
      # @return [Hash] 削除後パラメータ
      def reject_ransack_param(param)
        p = param.reject { |k, v| k.end_with?('_present') && (v.blank? || v.to_i.zero?) }
                 .with_indifferent_access
        p = p.except(*reject_ransack_keys)
        p = p.except(*premium_ransack_keys) unless premium_charging_member?
        p
      end

      # フリーワード検索のransackパラメータを作成
      # @return [Hash] 作成後パラメータ
      def freeword_ransack_param(param)
        freeword = param[:freeword_cont]
        return param if freeword.blank?
        param.delete(:freeword_cont)
        param[:g] = { '0' => { m: 'or', g: { '0' => { user_profile_comment_was_accepted_cont: freeword },
                                             '1' => { user_profile_school_name_was_accepted_cont: freeword },
                                             '2' => { user_profile_hobby_was_accepted_cont: freeword },
                                             '3' => { user_profile_job_name_was_accepted_cont: freeword },
                                             '4' => { user_profile_tweet_was_accepted_cont: freeword },
                                             '5' => { user_profile_good_place_was_accepted_cont: freeword }
        } } }
        param
      end

      def premium_user_ransack_param(param)
        now = Time.current
        param[:user_payments_enabled_eq] = true
        param[:user_payments_payment_type_eq] = 1
        param[:user_payments_start_at_lt] = now
        param[:user_payments_end_at_gt] = now
        param
      end
    end
  end
end
