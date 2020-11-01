# 女性のメッセージ送信バリデーション
module Logic
  module User
    module UserMatchMessage
      module FemaleUser
        extend ActiveSupport::Concern

        # チャットメッセージ処理を行う
        # @param [Integer] room_id ルームID
        # @param [String] message メッセージ
        # @raise バリデーションエラー
        def message_handling!(params)
          create_user_match_message!(params)
        end
      end
    end
  end
end
