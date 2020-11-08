module Versions
  module V1
    module TestUser
      extend ActiveSupport::Concern
      included do
        namespace :test do
          namespace :user do

            #auth :grape_devise_token_auth, resource_class: :user

            #helpers GrapeDeviseTokenAuth::AuthHelpers

            desc '認証のテスト ヘッダにaccess-token, client, uid が必要'
            get '' do
              @user = User#.without_soft_destroyed
                          .where('email = ?', 'admin@example.com').first
              @user.valid_password?('password')

              @user
              #authenticate_user!
              #{
              #  message: 'test',
              #  current_user_uid: current_user.uid,
              #  authenticated?: authenticated?,
              #}
            end

            desc 'ログインする'
            params do
              requires :id, type: String, desc: 'ID'
              requires :password, type: String, desc: 'パスード'
            end
            post :login, jbuilder: 'v1/users/login' do
              #user = UserForm.new(params)
              #api_transaction(user) do
                #user.validate!(:users_login)
              @user = User#.without_soft_destroyed
                            .where('email = ?', params[:id] + '@sample.com').first
                            #.where('authentication_token = ?', params[:token]).first
                raise_authenticate_error! unless @user && @user.valid_password?(params[:password])
              #end
            end

            desc 'ユーザー作成'
            params do
              requires :id, type: String, desc: 'id'
              requires :password, type: String, desc: 'パスード'
              requires :sex, type: Integer, desc: '性別'
            end
            post :create, jbuilder: 'v1/users/create' do
              p params
              p params[:id]
              params[:email] = params[:id] + '@sample.com'
              p params[:email]
              #params[:sex] = 0
              params[:prof_address_id] = 13
              user = UserForm.new(params)
              p user
              api_transaction(user) do
                user.validate!(:users_create)
                params[:authentication_token] = SecureRandom.hex(24)
                p params
                @user = User.create_by_request!(params)
              end
              #api_transaction(user) do
                #user.validate!(:users_login)
              #@user = User#.without_soft_destroyed
              #              .where('authentication_token = ?', params[:token]).first
              #  raise_authenticate_error! unless @user && @user.valid_password?(params[:password])
              #end
            end

          end
        end
      end
    end
  end
end
