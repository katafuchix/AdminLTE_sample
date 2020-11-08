module Versions
  module V1
    module TestUserProfile
      extend ActiveSupport::Concern
      included do
        namespace :test do
          namespace :user do
            namespace :profile do
              #auth :grape_devise_token_auth, resource_class: :user

              #helpers GrapeDeviseTokenAuth::AuthHelpers

              desc '自分のユーザープロフィールを取得する'
              params do
                requires :auth_token, type: String, desc: '認証トークン'
                optional :edit_type, type: String, desc: '入力タイプ("create"or"update")'
              end
              get '', jbuilder: 'v1/user_profiles/me_show' do
                authenticated!
                p @current_user
                p "\n"
                p @current_user.id
                p "\n"
                @user = User.includes(:user_profile).find(@current_user.id).try(:grant_gender)
                p @user
                #@user.edit_type = params[:edit_type]
              end

            end
          end
        end
      end
    end
  end
end
