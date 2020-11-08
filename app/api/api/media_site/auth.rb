module MediaSite
  module Auth
    extend ActiveSupport::Concern

    included do
      helpers do
        # 認証済み判定 - 未認証の場合例外発生無し
        def authenticated?
          return false unless params[:auth_token]
          @current_user = User.without_soft_destroyed.includes(:user_profile)
                              .find_by(authentication_token: params[:auth_token])
                              .try(:grant_gender)
        end

        # 認証済み判定 - 未認証の場合例外発生
        def authenticated!
          return true if authenticated?
          raise_authenticate_error!
        end

        # 認証エラーのJSONを出力する
        def raise_authenticate_error!
          unauthenticated_response = {
            message: I18n.t('api.errors.unauthentication'),
            error_code: Settings.api_error_code.unauthenticated
          }
          error!(unauthenticated_response, 401)
        end

        # ログイン中のユーザー
        def current_user
          @current_user
        end
      end
    end
  end
end
