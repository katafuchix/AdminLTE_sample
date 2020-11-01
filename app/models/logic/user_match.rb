module Logic
  module UserMatch
    extend ActiveSupport::Concern

    # マッチング相手のuser_idを取得する
    # @param [Integer] current_user_id 自分のID
    # @return [Integer] 相手のID
    def matching_target_user_id(current_user_id)
      user_id == current_user_id ? target_user_id : user_id
    end

    # マッチングのソート対象 メッセージが作成されたものを上位に表示する
    # @return [Date] ソート対象の日付
    def matching_list_sort_order
      return created_at if user_match_messages.blank?
      user_match_messages.latest.first.created_at
    end

    # 送信者IDから受信者IDを返す
    # @params [Integer] sender_user_id 送信者ID
    # @return [Integer] 受信者ID
    def receiver_user_id(sender_user_id)
      ([user_id, target_user_id] - [sender_user_id]).pop
    end

    # マッチングしたらPush通知送信
    def send_match_notification
      UserMatchMailer.create(user).deliver_later if user.sendable_match_mail?
      UserMatchMailer.create(target_user).deliver_later if target_user.sendable_match_mail?
      target_user.send_push_notification('user_match_mailer.create.push.body') if target_user.user_notify.match_push_notify
      user.send_push_notification('user_match_mailer.create.push.body') if user.user_notify.match_push_notify
    end

    # 既読処理 & メッセージ開封
    def read_and_open!(current_user)
      transaction do
        read!(current_user)
        if current_user.id == user_id
          update!(unread_count: 0)
        else
          update!(target_unread_count: 0)
        end
      end
    end

    # メッセージを既読にする
    # @param [User] current_user 自分
    def read!(current_user)
      transaction do
        current_user_unread_messages = user_match_messages.where(receiver_user: current_user, is_read: false)
        current_user_unread_messages.update_all(is_read: true)
        if current_user.id == target_user.id
          update(target_unread_count: 0)
        else
          update(unread_count: 0)
        end
      end
    end

    # メッセージの未読件数を更新する
    # @return [Booleam] true
    def reset_read_count!
      unread_message_count = user_match_messages.where(receiver_user: user, is_read: false).count
      target_unread_message_count = user_match_messages.where(receiver_user: target_user, is_read: false).count
      update!(unread_count: unread_message_count, target_unread_count: target_unread_message_count)
    end

    # unique_keyによるroom_idを取得
    def room_id_by_unique_key
      [user.unique_key, target_user.unique_key].sort.join('+')
    end

    # メッセージ付きいいねからuser_match_messagesを作成する
    def create_match_message_from_relation
      # メッセージ付きいいね取得
      relations = ::UserRelation.relation_messages_related_to_user_match_id(id).order_created_at
      relations.each do |relation|
        user_match_messages.create!(user_match_id: id,
                                    message: relation.message,
                                    sender_user_id: relation.user_id,
                                    receiver_user_id: relation.target_user_id)
      end
    end

    private

    # ルームIDを生成する
    # @return [String] ルームID
    def generate_room_id
      self.room_id = slice(:user_id, :target_user_id).values.sort.join('+')
    end
  end
end
