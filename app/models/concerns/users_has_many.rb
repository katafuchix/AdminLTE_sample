# Userにリレーションとスコープを追加します
# モデルの例としてUserRelationに追加する場合
# Userモデルにこちらを定義します
#   create_self_association :user_relations
#
# 追加されるリレーション
#   user_relations       : 自分からしたいいね : dependent: :destroy
#   incomming_relations  : 自分にされたいいね : dependent: :destroy
#   outcomming_relations : 自分からしたいいね : dependent: :destroy
#   incomming_relation_users : 自分にいいねしたユーザ
#   outcomming_relation_users : 自分がいいねしたユーザ
#
# 追加されるスコープ
#   @params [User] user
#   @return [User::ActiveRecord_AssociationRelation] ユーザ一覧
#
#   outcomming_unrelationed_users : 自分がいいねしていないユーザ
#   incomming_unrelationed_users : 自分にいいねしていないユーザ
#   mutual_unrelationed_users : お互いにいいねしていないユーザ
#   mutual_relation_users : お互いにいいねしているユーザ
#   related_relation_users : 片方orお互いにいいねしているユーザ
module UsersHasMany
  extend ActiveSupport::Concern

  class_methods do
    # ユーザーの自己結合アソシエーションを定義する
    # @params [String or Symbol] has_manyの引数
    # @return [Boolean] 成功したかどうか
    def create_self_association(name)
      unuser_name = name.to_s.gsub('user_', '')
      short_name = unuser_name.singularize
      class_name = name.to_s.classify
      create_has_many(name, unuser_name, short_name, class_name)
      create_scope(short_name)
      create_complex_scope(short_name)
    end

    private

    def create_has_many(name, unuser_name, short_name, class_name)
      # 自分のアクション
      has_many :"#{name}", dependent: :destroy
      # 自分にされたアクション
      has_many :"incomming_#{unuser_name}", class_name: class_name, foreign_key: :target_user_id, dependent: :destroy
      # 自分にアクションしたユーザー
      has_many :"incomming_#{short_name}_users", through: :"incomming_#{unuser_name}", source: :user
      # 自分のアクション
      has_many :"outcomming_#{unuser_name}", class_name: class_name, dependent: :destroy
      # 自分がアクションしたユーザー
      has_many :"outcomming_#{short_name}_users", through: :"outcomming_#{unuser_name}", source: :target_user
    end

    def create_scope(short_name)
      # 自分がアクションしていないユーザー
      scope :"outcomming_un#{short_name}ed_users", lambda { |user|
        where.not(id: user.public_send("outcomming_#{short_name}_user_ids"))
      }
      # 自分がアクションされていないユーザー
      scope :"incomming_un#{short_name}ed_users", lambda { |user|
        where.not(id: user.public_send("incomming_#{short_name}_user_ids"))
      }
      # お互いにアクションされていないユーザー
      scope :"mutual_un#{short_name}ed_users", lambda { |user|
        public_send("outcomming_un#{short_name}ed_users", user).public_send("incomming_un#{short_name}ed_users", user)
      }
    end

    def create_complex_scope(short_name)
      # お互いにアクションしているユーザー
      scope :"mutual_#{short_name}_users", lambda { |user|
        where(id: user.public_send("outcomming_#{short_name}_users") & user.public_send("incomming_#{short_name}_users"))
      }
      # 少なくとも一方からアクションしているユーザー
      scope :"related_#{short_name}_users", lambda { |user|
        where(id: user.public_send("outcomming_#{short_name}_user_ids") + user.public_send("incomming_#{short_name}_user_ids"))
      }
    end
  end
end
