# お知らせを既読にする
# 送信可能か判定する
module Logic
  module User
    module UserNotification
      extend ActiveSupport::Concern

      # APIリクエストからお知らせ一覧を取得する
      # @return [Array] お知らせ一覧
      def notifications
        (::UserNotification.where(user_id: id) + ::CommonNotification.readable(self)).sort { |a, b| b.created_at <=> a.created_at }
      end

      # APIリクエストからお知らせを全て既読処理する
      def read_all_notification!
        all_reads = user_notification_reads
        read_common_notification_ids = all_reads.select { |s| s.notificatable_type == 'CommonNotification' }.pluck(:notificatable_id)
        unread_common_notifications = ::CommonNotification.readable(self).where.not(id: read_common_notification_ids)
        unread_common_notifications.each do |n|
          user_notification_reads.create(notificatable_type: 'CommonNotification', notificatable_id: n.id)
        end
        read_user_notification_ids = all_reads.select { |s| s.notificatable_type == 'UserNotification' }.pluck(:notificatable_id)
        unread_user_notifications = user_notifications.where.not(id: read_user_notification_ids)
        unread_user_notifications.each do |n|
          user_notification_reads.create(notificatable_type: 'UserNotification', notificatable_id: n.id)
        end
      end

      # メール送信可能なユーザーか判定する
      def sendable_mail_user?
        email.present? && deleted_at.blank?
      end

      # メール送信可能か判定する(いいね)
      # @return [Boolean] 判定結果
      def sendable_relation_mail?
        sendable_mail_user? && user_notify.relation_mail_notify
      end

      # メール送信可能か判定する(マッチング)
      # @return [Boolean] 判定結果
      def sendable_match_mail?
        sendable_mail_user? && user_notify.match_mail_notify
      end

      # メール送信可能か判定する(メッセージ)
      # @return [Boolean] 判定結果
      def sendable_match_message_mail?
        sendable_mail_user? && user_notify.match_message_mail_notify
      end

      # メール送信可能か判定する(足あと)
      # @return [Boolean] 判定結果
      def sendable_visitor_message_mail?
        sendable_mail_user? && user_notify.visitor_mail_notify
      end

      # メール送信可能か判定する(通常お知らせ)
      # @return [Boolean] 判定結果
      def sendable_notification_mail?
        sendable_mail_user? && user_notify.notification_mail_notify
      end
    end
  end
end
