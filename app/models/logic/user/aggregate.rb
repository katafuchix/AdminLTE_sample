module Logic
  module User
    module Aggregate
      extend ActiveSupport::Concern
      # マッチング済みのuser_matchesレコード一覧を取得
      # @return [Array] user_matchesレコード一覧
      def mutual_matchs
        (outcomming_matchs + incomming_matchs).uniq(&:id)
      end

      # アプリアイコン等に表示するバッジ数取得
      # @return [Integer] バッジ数
      def badge_count
        count = 0
        # お知らせ未読数
        all_reads = user_notification_reads
        read_common_notification_ids = all_reads.select { |s| s.notificatable_type == 'CommonNotification' }.pluck(:notificatable_id)
        unread_common_notifications = ::CommonNotification.readable(self).where.not(id: read_common_notification_ids)
        count += unread_common_notifications.length
        read_user_notification_ids = all_reads.select { |s| s.notificatable_type == 'UserNotification' }.pluck(:notificatable_id)
        unread_user_notifications = user_notifications.where.not(id: read_user_notification_ids)
        count += unread_user_notifications.length
        count
      end

      # いいね数総計
      # @return [Integer] いいね数
      def all_relation_point
        relation_point + remain_relation_count
      end
    end
  end
end
