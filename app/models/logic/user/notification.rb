# 通知送信
module Logic
  module User
    module Notification
      extend ActiveSupport::Concern
      # メールアドレス確認メールを送信
      def sendmail_user_verify
        ApplicationMailer.sendmail_user_verify(self).deliver_later_later
      end

      # Push通知を送信する
      # @params [String] i18nの変換キー
      # @return [Boolean] 成功したかどうか
      # @raise [NoMethodError] お知らせが定義されていません
      def send_push_notification(i18n_key, params = {}, link_params = {})
        return false if deleted_at.present?
        return false unless can_notify?(i18n_key)
        # ※ formatで例外が発生した場合は変換無しで返却
        alert = begin
                  format(I18n.t!(i18n_key), params)
                rescue
                  I18n.t!(i18n_key)
                end
        push_link_i18n = I18n.t(i18n_key.gsub('push', 'push_link'), default: '')
        push_link = begin
                      format(push_link_i18n, link_params)
                    rescue
                      push_link_i18n
                    end
        send_push_notification_with_alert(alert, push_link)
      end

      # Push通知を送信する
      # @params [String] 送信メッセージ
      # @params [String] プッシュ通知タップリンク
      # @return [Boolean] 成功したかどうか
      # @raise [NoMethodError] お知らせが定義されていません
      def send_push_notification_with_alert(alert, push_link = nil)
        return false if deleted_at.present?
        PushNotificationJob.perform_later(device_token: device_token,
                                          device_token_android: device_token_android,
                                          content_available: true,
                                          alert: alert,
                                          data: { push_link: push_link }
                                         ) if device_token || device_token_android
      end

      # 違反報告のお礼メールを送信する
      # @param [String] mail_message メールメッセージ
      def send_violation_gratitude_message(mail_message)
        if email.present? && deleted_at.blank?
          UserViolationMailer.create(self, mail_message).deliver_later
        end
      end

      private

      def can_notify?(i18n_key)
        notification_category = i18n_key.split('.')[0].split('_')[1..-2].join('_')
        msg = I18n.t('not_defined', scope: :push, i18n_key: i18n_key)
        fail NoMethodError, msg unless user_notify.respond_to?("#{notification_category}_push_notify")
        fail NoMethodError, msg unless I18n.exists?(i18n_key) && i18n_key.include?('push')
        user_notify.public_send("#{notification_category}_push_notify")
      end
    end
  end
end
