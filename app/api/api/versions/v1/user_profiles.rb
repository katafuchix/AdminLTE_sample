module Versions
  module V1
    module UserProfiles
      extend ActiveSupport::Concern
      included do

          namespace :me do
            namespace :profile do
              desc '自分のユーザープロフィールを更新する'
              params do
                requires :auth_token, type: String, desc: '認証トークン'
                requires :edit_type, type: String, desc: '入力タイプ("create"or"update")'
                optional :comment, type: String, desc: '自己紹介'
                optional :good_place, type: String, desc: 'よく行く場所'
                optional :date_place, type: String, desc: '初回デートで行きたい場所'
                optional :name, type: String, desc: 'ニックネーム'
                optional :blood_id, type: Integer, desc: '血液型'
                optional :dream, type: String, desc: '将来の夢'
                optional :prof_expect_support_money_id, type: Integer, desc: '希望支援金額'
                optional :prof_first_date_cost_id, type: String, desc: '初デート費用'
                optional :prof_address_id, type: Integer, desc: '居住地'
                optional :prof_job_id, type: Integer, desc: '職種'
                optional :prof_educational_background_id, type: Integer, desc: '学歴'
                optional :height, type: Integer, desc: '身長'
                optional :prof_figure_id, type: Integer, desc: '体型'
                optional :prof_smoking_habit_id, type: Integer, desc: 'タバコ'
                optional :prof_drinking_habit_id, type: Integer, desc: 'お酒'
                optional :prof_birth_place_id, type: Integer, desc: '出身地'
                optional :prof_annual_income_id, type: Integer, desc: '年収'
                optional :prof_holiday_id, type: Integer, desc: '休日'
                optional :prof_marriage_id, type: Integer, desc: '結婚'
                optional :prof_have_child_id, type: Integer, desc: '子供'
                optional :school_name, type: String, desc: '学校名'
                optional :job_name, type: String, desc: '職業名'
                optional :hobby, type: String, desc: '好きなこと・趣味'
                optional :prof_personality_id, type: Integer, desc: '性格'
                optional :prof_request_until_meet_id, type: Integer, desc: '出会うまでの希望'
                optional :tweet, type: String, desc: '一言コメント'
                optional :background_image, type: String, desc: '背景画像'
                optional :personality_list, type: Array[Integer], coerce_with: ->(val) { val.split(/\D/).reject(&:blank?) }
              end
              post :update, jbuilder: 'v1/user_profiles/update' do
                authenticated!
                db_transaction do
                  current_user.edit_type = params[:edit_type]
                  @user = current_user.update_profile!(params)
                  if params[:personality_list].present?
                    current_user.user_profile.personality_list = params[:personality_list]
                    current_user.user_profile.save!
                  end
                end
              end

              desc '自分のユーザープロフィールを取得する'
              params do
                requires :auth_token, type: String, desc: '認証トークン'
                optional :edit_type, type: String, desc: '入力タイプ("create"or"update")'
              end
              get '', jbuilder: 'v1/user_profiles/me_show' do
                authenticated!
                @user = User.includes(user_profile: UserProfile.eager_loading_list).find(current_user.id).try(:grant_gender)
                #@user.edit_type = params[:edit_type]
              end

              namespace :birthday do
                desc '自分の生年月日を更新する'
                params do
                  requires :auth_token, type: String, desc: '認証トークン'
                  requires :birthday, type: String, desc: '生年月日'
                  optional :edit_type, type: String, desc: '入力タイプ("create"or"update")'
                end
                post :update, jbuilder: 'v1/user_profiles/update_birthday' do
                  authenticated!
                  db_transaction do
                    current_user.edit_type = params[:edit_type]
                    @user = current_user.user_profile.update_birthday_only_once!(params)
                  end
                end
              end
            end
          end

          route_param :id do
            namespace :profile do
              desc '異性のユーザープロフィールを取得する'
              params do
                requires :auth_token, type: String, desc: '認証トークン'
                optional :example, type: Integer, desc: 'プロフィール例文(同性プロフィールも表示)'
              end
              get '', jbuilder: 'v1/user_profiles/show' do
                example = params[:example].present?
                authenticated!
                check_set_sex!
                @user = User.includes(user_profile: UserProfile.eager_loading_list).find_by(id: params[:id])
                check_empty!(@user)
                check_other_sex!(@user) unless example
                break if example
                break unless current_user.visitor_log
                unless current_user.outcomming_visitors.day.exists?(target_user_id: @user.id)
                  UserVisitorMailer.create(@user).deliver_later if @user.sendable_visitor_message_mail?
                  @user.send_push_notification('user_notification_mailer.notify_visitor.push') if @user.user_notify.visitor_push_notify
                  current_user.outcomming_visitors.day.find_or_create_by(target_user: @user).try(:touch)
                end
              end
            end
          end

      end
    end
  end
end
