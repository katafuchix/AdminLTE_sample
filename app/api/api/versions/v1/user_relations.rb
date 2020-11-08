# rubocop:disable Metrics/ModuleLength
module Versions
  module V1
    module UserRelations
      extend ActiveSupport::Concern
      included do
        namespace :users do
          namespace :outcomming do
            namespace :relations do
              desc 'いいねした異性を取得する'
              params do
                requires :auth_token, type: String, desc: '認証トークン'
                optional :page, type: Integer, desc: 'ページ番号'
              end
              get '', jbuilder: 'v1/user_profiles/list' do
                authenticated!
                check_set_sex!
                @page = params[:page] || 1
                @users = current_user
                         .outcomming_active_relation_users
                         .where.not(user_relations: { target_user_id: current_user.outcomming_relation_users_skipped.ids })
                         .without_soft_destroyed
                         .mutual_unblocked_users(current_user)
                         .mutual_unmatched_users(current_user)
                         .outcomming_undisplayed_users(current_user)
                         .page(@page).per(Settings.paging_per.user_relation.outcomming)
                         .order('users.updated_at DESC')
                         .includes(:user_payments, user_profile: UserProfile.eager_loading_list)
                         #.includes(user_profile: UserProfile.eager_loading_list)
              end

              desc '異性をいいねする'
              params do
                requires :auth_token, type: String, desc: '認証トークン'
                requires :target_user_id, type: String, desc: 'お相手のユーザID'
                optional :message, type: String, desc: 'メッセージ'
              end
              post :create, jbuilder: 'v1/user_relations/create' do
                authenticated!
                check_set_sex!
                db_transaction do
                  p params
                  p params.slice(:target_user_id, :message).merge(user_id: current_user.id)
                  #relation = UserRelation.create!(params.slice(:target_user_id, :message).merge(user_id: current_user.id))
                  relation = ::UserRelation.new(params.slice(:target_user_id, :message).merge(user_id: current_user.id))
                  relation.save!
                  p relation
                  #relation.refresh_user_relation_count!
                  #current_user.reload
                  #@user_relation = current_user.user_relations.find_by(params.slice(:target_user_id))
                end
              end

              desc '異性をいいねする(ユーザー作成時)'
              params do
                requires :auth_token, type: String, desc: '認証トークン'
                requires :target_user_ids, type: Array[Integer], coerce_with: ->(val) { val.split(',') }, desc: 'お相手のユーザIDの配列 例）1,2,3'
              end
              post :create_at_registration, jbuilder: 'v1/user_relations/create_at_registration' do
                authenticated!
                check_set_sex!
                db_transaction do
                  fail StandardError, I18n.t('api.errors.relation_completed_registration') if current_user.complete_registration
                  params[:target_user_ids].each do |user_id|
                    relation = UserRelation.create!(user_id: current_user.id, target_user_id: user_id, skip_use_relation_point: true)
                    relation.refresh_user_relation_count!
                  end
                  current_user.reload
                  @user_relations = current_user.user_relations.where(target_user_id: params[:target_user_ids])
                end
              end
            end
          end
          namespace :incomming do
            namespace :relations do
              desc 'いいねしてくれた異性を取得する'
              params do
                requires :auth_token, type: String, desc: '認証トークン'
                optional :page, type: Integer, desc: 'ページ番号'
              end
              get '', jbuilder: 'v1/user_profiles/incomming_relation_list' do
                authenticated!
                check_set_sex!
                @page = params[:page] || 1
                @users = current_user
                         .incomming_active_relation_users
                         .where.not(user_relations: { user_id: current_user.outcomming_relation_users_skipped.ids })
                         .where.not(user_relations: { user_id: current_user.outcomming_pending_relation_users.ids })
                         .without_soft_destroyed
                         .mutual_unmatched_users(current_user)
                         .mutual_unblocked_users(current_user)
                         .outcomming_undisplayed_users(current_user)
                         .page(@page).per(Settings.paging_per.user_relation.incomming)
                         .order('users.updated_at DESC')
                         .includes(:user_payments, user_profile: UserProfile.eager_loading_list)
                @relation_messages = current_user.incomming_active_relations.where(user_id: @users.pluck(:id))
              end

              desc 'いいね数を取得する'
              params do
                requires :auth_token, type: String, desc: '認証トークン'
              end
              get 'count', jbuilder: 'v1/user_relations/count' do
                authenticated!
                @count = current_user
                         .incomming_active_relation_users
                         .without_soft_destroyed
                         .mutual_unmatched_users(current_user)
                         .mutual_unblocked_users(current_user)
                         .outcomming_undisplayed_users(current_user).length
              end

              desc 'いいねをスキップする'
              params do
                requires :auth_token, type: String, desc: '認証トークン'
                requires :target_user_id, type: String, desc: 'お相手のユーザID'
              end
              post 'skip', jbuilder: 'v1/user_relations/skip' do
                authenticated!
                relation = UserRelation.where(user_id: params[:target_user_id], target_user_id: current_user.id).first
                relation.skipped = true
                relation.save!
              end

              desc 'いいねをスキップしたユーザーを取得する'
              params do
                requires :auth_token, type: String, desc: '認証トークン'
                optional :page, type: Integer, desc: 'ページ番号'
              end
              get 'skipped', jbuilder: 'v1/user_profiles/list' do
                authenticated!
                check_set_sex!
                @page = params[:page] || 1
                @users = current_user
                         .incomming_active_relation_users
                         .without_soft_destroyed
                         .mutual_unmatched_users(current_user)
                         .mutual_unblocked_users(current_user)
                         .outcomming_undisplayed_users(current_user)
                         .where(user_relations: { skipped: true })
                         .page(@page).per(Settings.paging_per.user_relation.incomming)
                         .order('user_relations.updated_at DESC')
                         .includes(:user_payments, user_profile: UserProfile.eager_loading_list)
              end
            end
          end
        end
      end
    end
  end
end
# rubocop:enable Metrics/ModuleLength
