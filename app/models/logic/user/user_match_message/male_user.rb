# 男性のメッセージ送信
# ポイント使用
# 無料男性会員の２通目メッセージのときのエラー

module Logic
  module User
    module UserMatchMessage
      module MaleUser
        extend ActiveSupport::Concern

        class CustomException < StandardError
          attr_reader :error_code
          def initialize(error_code)
            @error_code = error_code
            super
          end
        end

        # チャットメッセージ処理を行う
        # @param [Hash] params パラメーター
        # @raise バリデーションエラー
        def message_handling!(params)
          if ::UserMatch.find_by(room_id: params[:room_id]).blank? || ::UserMatch.find_by(room_id: params[:room_id])
                                                                                 .user_match_messages
                                                                                 .where(sender_user_id: id).blank?
            can_message_save?(params) if no_charging_member?
          else
            no_charging_member_too_message!(params[:room_id])
          end
          use_send_message_point!
          create_user_match_message!(params)
        end

        private

        # ポイント消費
        def use_send_message_point!
          use_point!(::ManagePoint.find_by(key: 'send_message').point)
        end

        # 無料会員が同じ相手に２通目のメッセージを送った時のエラー
        def no_charging_member_too_message!(_room_id)
          fail CustomException.new(Settings.api_error_code.denied), ::I18n.t('api.errors.no_charging_member_too_message') if no_charging_member?
        end

        def can_message_save?(params)
          regexp_ary = [/[\w+\-.]+@[a-z\d\-.]+\.[a-z]+/i, /0[6-9]0\d{8}/, /[\w+\-.]{6,20}+/i]
          regexp_ary.each do |regexp|
            if params[:message].match(regexp).present?
              fail StandardError, ::I18n.t('api.errors.invalid_message')
            end
          end
          fail StandardError, ::I18n.t('api.errors.invalid_first_message') if params[:image].present?
        end
      end
    end
  end
end
