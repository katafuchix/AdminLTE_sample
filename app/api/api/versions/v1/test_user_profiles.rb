module Versions
  module V1
    module TestUserProfiles
      extend ActiveSupport::Concern
      included do
        namespace :test do
          namespace :user do
            namespace :profiles do
              #auth :grape_devise_token_auth, resource_class: :user

              #helpers GrapeDeviseTokenAuth::AuthHelpers

              desc '自分のユーザープロフィールを取得する'
              params do
                requires :auth_token, type: String, desc: '認証トークン'
                optional :edit_type, type: String, desc: '入力タイプ("create"or"update")'
              end
              get '', jbuilder: 'v1/user_profiles/me_show' do
                authenticated!
                p "\n"
                p @current_user
                p "\n"
                p "23"
                profiles = User.includes(:user_profile).where('users.id = ?', @current_user.id)#.find(current_user.id)
                p "25"
                puts profiles.to_s
                #profiles.each do |profile|
                #  puts profile.to_s
                #end
                p "26"
                @user = @current_user
                #User.includes(user_profile: UserProfile.eager_loading_list).find(current_user.id)#.try(:grant_gender)
                #@user = User.includes(user_profile: :user_profile).find(current_user.id)#.try(:grant_gender)

                #User.includes(:user_profile).references(:user_profile).find(current_user.id)#.try(:grant_gender)

                #@user = User.includes(:user_profile).where('users.id = ?', @current_user.id)
                @user = User.find_by(id: @current_user.id)
                p "24"

                User.includes(:user_profile).select("users.*, user_profiles.*").first.email
                P "end"
              end

            end
          end
        end
      end
    end
  end
end
