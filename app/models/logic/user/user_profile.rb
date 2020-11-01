module Logic
  module User
    module UserProfile
      extend ActiveSupport::Concern
      # APIのリクエストによりユーザープロフィールの更新を行う
      # @param [Hash] params APIリクエストパラメータ
      # @raise バリデーションエラー
      def update_profile!(params)
        #user_profile.remove_background_image! if params[:background_image].nil?
        user_profile.update_by_request!(params)
      end
    end
  end
end
