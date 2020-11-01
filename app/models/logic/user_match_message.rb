module Logic
  module UserMatchMessage
    extend ActiveSupport::Concern

    # メッセージを開封可能か
    # @param [Model] user ユーザー
    # @return [Boolean] 判定
    def can_open_message?(user)
      !(user.sex == 'male' &&
        !user.normal_charging_member? &&
        user.id != sender_user_id)
    end

    # メッセージのJSONデータをRedisに保存
    def cache_user_match_message(relation, timestamp, timedays)
      data = {
        'room' => relation.user_match.room_id_by_unique_key,
        'id' => timestamp,
        'content' => message,
        'image_url' => image.try(:url),
        'created_at' => created_at.strftime('%H:%M'),
        'fromID' => sender_user_id,
        'timestamp' => timestamp,
        'timedays' => timedays
      }
      begin
        Redis.current.publish('message_from_rails', ActiveSupport::JSON.encode(data))
      rescue
        nil
      end
    end

    # メッセージ未読更新
    def update_message_unread
      # 未読数更新
      user_match.reset_read_count!
    end
  end
end
