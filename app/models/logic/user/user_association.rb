# ユーザどおしの関係性
module Logic
  module User
    module UserAssociation
      extend ActiveSupport::Concern

      # ユーザーとの関係の存在を返す
      # @return [Hash] いいね、マッチング、お気に入り、ブロック関係があるかどうか
      def self_association_with_user(user)
        self_association_user_ids_with_dates_hash.each_with_object({}) do |(k, v), h|
          h[k] = v.include?(user.id) && v.find_index(user.id).nil? ? v[user.id] : v.include?(user.id)
        end
      end

      # rubocop:disable all
      # 紐づいているユーザーのIDをハッシュで返す
      # @return [Hash] いいね、マッチング、お気に入り、ブロック関係ごとのユーザのID, とそれぞれのレコードの作成日
      def self_association_user_ids_with_dates_hash
        return @self_association_user_ids_with_dates_hash if @self_association_user_ids_with_dates_hash.present?
        @self_association_user_ids_with_dates_hash = {
          outcomming_relation: outcomming_active_relation_user_ids,
          outcomming_relation_at: outcomming_active_relations.pluck(:target_user_id, :created_at).to_h,
          incomming_relation: incomming_active_relation_user_ids,
          incomming_relation_at: incomming_active_relations.pluck(:user_id, :created_at).to_h,
          incomming_relation_message: incomming_active_relations.message_accepted.pluck(:user_id, :message_was_accepted).to_h,
          outcomming_pending_relation: outcomming_pending_relation_user_ids,
          outcomming_pending_relation_at: outcomming_pending_relations.pluck(:target_user_id, :created_at).to_h,
          outcomming_match: outcomming_match_user_ids,
          outcomming_match_at: outcomming_matchs.pluck(:target_user_id, :created_at).to_h,
          incomming_match: incomming_match_user_ids,
          incomming_match_at: incomming_matchs.pluck(:user_id, :created_at).to_h,
          outcomming_block: outcomming_block_user_ids,
          outcomming_block_at: outcomming_blocks.pluck(:target_user_id, :created_at).to_h,
          incomming_block: incomming_block_user_ids,
          incomming_block_at: incomming_blocks.pluck(:user_id, :created_at).to_h,
          outcomming_favorite: outcomming_favorite_user_ids,
          outcomming_favorite_at: outcomming_favorites.pluck(:target_user_id, :created_at).to_h,
          incomming_favorite: incomming_favorite_user_ids,
          incomming_favorite_at: incomming_favorites.pluck(:user_id, :created_at).to_h
        }
      end

      #rubocop:enable all
    end
  end
end
