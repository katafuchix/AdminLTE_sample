module Versions
  module V1
    module ProfileImages
      extend ActiveSupport::Concern
      included do
        namespace :users do
          namespace :me do
            namespace :profile do
              namespace :images do
                desc '自分のユーザープロフィール画像を登録する'
                params do
                  requires :auth_token, type: String, desc: '認証トークン'
                  requires :image, type: String, desc: '登録画像Base64', allow_blank: false
                end
                post :create, jbuilder: 'v1/profile_images/create' do
                  authenticated!
                  db_transaction do
                    current_user.user_profile.create_images_by_request!(params)
                  end
                end

                desc '自分のユーザープロフィール画像を更新する'
                params do
                  requires :auth_token, type: String, desc: '認証トークン'
                  requires :image, type: String, desc: '登録画像Base64', allow_blank: false
                  requires :target_sort_order, type: Integer, desc: '変更先画像番号', allow_blank: false
                end
                post :update, jbuilder: 'v1/profile_images/update' do
                  authenticated!
                  db_transaction do
                    current_user.user_profile.update_image_by_request!(params)
                  end
                end

                desc '自分のユーザープロフィール画像を並び替える'
                params do
                  requires :auth_token, type: String, desc: '認証トークン'
                  requires :start_sort_order, type: Integer, desc: '変更元画像番号', allow_blank: false
                  requires :end_sort_order, type: Integer, desc: '変更先画像番号', allow_blank: false
                end
                post :update_sort, jbuilder: 'v1/profile_images/update_sort' do
                  authenticated!
                  db_transaction do
                    current_user.user_profile.update_image_sort_by_request!(params)
                  end
                end

                desc '自分のユーザープロフィール画像を削除する'
                params do
                  requires :auth_token, type: String, desc: '認証トークン'
                  requires :target_sort_order, type: Integer, desc: '削除対象画像番号', allow_blank: false
                end
                post :delete, jbuilder: 'v1/profile_images/delete' do
                  authenticated!
                  db_transaction do
                    current_user.user_profile.delete_image_sort_by_request!(params)
                  end
                end

                desc '自分のユーザープロフィール画像を取得する'
                params do
                  requires :auth_token, type: String, desc: '認証トークン'
                end
                get '/:sort_order', jbuilder: 'v1/profile_images/show' do
                  authenticated!
                  @profile_image = ProfileImage.find_by(user_profile_id: current_user.user_profile.id,
                                                        sort_order: params[:sort_order])
                  check_empty!(@profile_image)
                end

                desc '自分のプロフィール画像の権限を変更する'
                params do
                  requires :auth_token, type: String, desc: '認証トークン'
                  requires :target_sort_order, type: Integer, desc: '権限変更対象画像番号'
                  requires :target_role, type: Integer, desc: '変更対象権限'
                end
                post :update_role, jbuilder: 'v1/profile_images/update_role' do
                  authenticated!
                  db_transaction do
                    current_user.user_profile.update_image_role_by_request!(params)
                  end
                end
              end
            end
          end

          route_param :user_id do
            namespace :profile do
              namespace :images do
                desc '異性のユーザープロフィール画像を取得する'
                params do
                  requires :auth_token, type: String, desc: '認証トークン'
                end
                get '/:sort_order', jbuilder: 'v1/profile_images/show' do
                  authenticated!
                  check_set_sex!
                  user = User.includes(:user_profile).find_by(id: params[:user_id])
                  check_empty!(user)
                  check_other_sex!(user)
                  @profile_image = ProfileImage.find_by(user_profile_id: user.user_profile.id,
                                                        sort_order: params[:sort_order])
                  check_empty!(@profile_image)
                end
              end
            end
          end
        end
      end
    end
  end
end
