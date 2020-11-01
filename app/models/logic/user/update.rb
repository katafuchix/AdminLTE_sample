module Logic
  module User
    module Update
      extend ActiveSupport::Concern
      # APIのリクエストによりユーザーのメール認証を行う
      # @param [Hash] params APIリクエストパラメータ
      # @raise バリデーションエラー
      def confirm_email!(params)
        u = ::User.confirm_by_token(params[:confirmation_token])
        fail StandardError, I18n.t('email_confirm.failure.invalid_token') unless u.errors.empty?
        save!
        add_point!(Settings.pater_point.email_confirmed, 'email_confirmed')
        user_notifications.create!(email_confirmed_params)
      end

      # APIのリクエストによりユーザーのデバイストークン登録を行う
      # @param [Hash] params APIリクエストパラメータ
      # @raise バリデーションエラー
      def update_device_token!(params)
        user = raw_user_record
        user.attributes = params.slice(:device_token, :device_token_android)
        user.save!
      end

      # Deviseのprivate内のメソッドを電話番号でパスワード変更するときのために定義
      def set_reset_password_token
        raw, enc = Devise.token_generator.generate(self.class, :reset_password_token)
        self.reset_password_token = enc
        self.reset_password_sent_at = Time.now.utc
        save(validate: false)
        raw
      end

      private

      def email_confirmed_params
        {
          notice_type: 0, title: I18n.t('api.success_message.user.update.certified_email_notify_title'),
          body: I18n.t('api.success_message.user.update.certified_email_notify_message', point: Settings.pater_point.email_confirmed)
        }
      end

      module ClassMethods
        # APIのリクエストによりリセットパスワードトークン発行&メール送信する
        # @param [Hash] params APIリクエストパラメータ
        def forgot_password!(params)
          fail I18n.t('api.errors.lack_request_param', lack_param: 'パラメーター') unless params[:email] || params[:mobile_phone]
          if params[:email]
            user = ::User.find_by(params.slice(:email))
            if user
              user.send_reset_password_instructions
              return
            end
          elsif params[:mobile_phone]
            user = ::User.find_by(params.slice(:mobile_phone))
            if user
              reset_password_token = ::User.send_reset_password_instructions(params)
              url = BitlyUtil.bitly_shorten(Rails.application.routes.url_helpers.edit_user_password_url(reset_password_token: reset_password_token))
              user.send_sms_with_message(user.mobile_phone, I18n.t('sms_verification.reset_password', url: url))
              return
            end
          end
          fail I18n.t('api.errors.user_not_exist')
        end
      end
    end
  end
end
