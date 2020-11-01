module Logic
  module User
    module Destroy
      extend ActiveSupport::Concern
      # 退会しているユーザーのユニーク情報を別データに退避させる
      # 強制退会させたユーザーのユニーク情報はそのまま保持し、同じメールアドレス、電話番号で再登録できないようにする
      # @raise バリデーションエラー
      def replace_withdrawal_user_unique_column!
        return unless pass_recreate_ban_term?
        return if is_forced_withdrawal?
        attr_ary = configure_withdrawal_user_unique_column_for_query(Time.current.to_i)
        update_phone_number = attr_ary[0]
        update_email = attr_ary[1]
        sql = "UPDATE users SET #{update_email} #{update_phone_number} mobile_phone=NULL, unconfirmed_mobile_phone=NULL WHERE id=#{id}"
        ActiveRecord::Base.connection.execute(sql)
      end

      # 退会処理
      # @param [String] mail_message メールメッセージ
      def withdrawal!(mail_message = '')
        soft_destroy!
        raw_user_record.update!(withdrawal_user_email: email, withdrawal_user_mobile_phone: mobile_phone)
        if deleted_at.present?
          if email.present?
            send_mail_to_leaving_user(mail_message)
          else
            send_sms_to_leaving_user(mail_message) unless Rails.env.test?
          end
        end
        user_notify.update(user_notify.attributes.map { |column| [column[0], false] if column[1] == true }.compact.to_h)
      end

      private

      def send_mail_to_leaving_user(message)
        if is_forced_withdrawal
          UserLeavingMailer.create(self, message, I18n.t('user_leaving_mailer.create.forced_subject')).deliver_later
        else
          UserLeavingMailer.create(self, message, I18n.t('user_leaving_mailer.create.subject')).deliver_later
        end
      end

      def send_sms_to_leaving_user(message)
        sms_message = [message, I18n.t('footer')].join("\n")
        send_sms_with_message(mobile_phone, sms_message)
      end

      def configure_withdrawal_user_unique_column_for_query(current_time = Time.current.to_i)
        update_phone_number = ''
        update_email = ''
        update_phone_number = "withdrawal_user_mobile_phone='#{mobile_phone}'," if mobile_phone.present?
        if email.present?
          temp_email = email + "-OldAccount-#{current_time}"
          update_email = "email='#{temp_email}',"
        end
        [update_phone_number, update_email]
      end
    end
  end
end
