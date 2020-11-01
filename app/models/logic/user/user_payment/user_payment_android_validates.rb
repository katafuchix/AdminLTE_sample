require 'google/apis/androidpublisher_v2'

module Logic
  module User
    module UserPayment
      module UserPaymentAndroidValidates
        extend ActiveSupport::Concern

        private

        # レシートの検証
        # @param [Hash] params auth_token、product_id、purchase_data、signature等を含むパラメーター
        # @param [Json] receipt purchase_dataのJSON
        def validate_android_receipt!(params, receipt)
          error_msg = I18n.t('api.errors.purchase.invalid_receipt')

          # Google側に問い合わせ
          validate_receipt_by_google!(params, error_msg)

          # 重複チェック・攻撃検知の為にhistory残すのでこのタイミングで。
          validate_unused_receipt!(receipt, error_msg)

          # 値チェック
          validate_package_name!(receipt, error_msg)
          validate_product_id!(params, receipt, error_msg)
          validate_purchase_state!(receipt, error_msg)
          validate_developer_payload!(receipt, error_msg)
        end

        # 未使用のレシートかどうか
        def validate_unused_receipt!(receipt, _error_msg)
          fail InvalidTransaction, I18n.t('api.errors.purchase.invalid_used_receipt') if exist_result_ok_history?(receipt['orderId'])
        end

        # レシート情報が改ざんされていないか
        # @raise エラー
        def validate_receipt_by_google!(params, error_msg)
          verifier = OpenSSL::PKey::RSA.new(open(Settings.android.public_pem))
          fail InvalidReceipt, error_msg unless verifier.verify(
            OpenSSL::Digest::SHA1.new,
            Base64.decode64(params[:signature]),
            params[:purchase_data])
        end

        # packageNameが合っているか
        # @raise エラー
        def validate_package_name!(receipt, error_msg)
          fail InvalidReceipt, "#{error_msg} : invalid product_id" unless receipt['packageName'] == Settings.android.package_name
        end

        # productIdが合っているか
        # @raise エラー
        def validate_product_id!(params, receipt, error_msg)
          # リストアの時はparams[:product_id]がない
          return if params[:product_id].blank?
          fail InvalidProductId, "#{error_msg} : invalid product_id" unless params[:product_id] == receipt['productId']
        end

        # purchaseStateが正しいか
        # @raise エラー
        def validate_purchase_state!(receipt, error_msg)
          status = receipt['purchaseState'].to_i
          fail AndroidServerConnectionError, 'Android server connection error' if status == 2
          fail InvalidReceipt, "#{error_msg} : status not 0" unless status == 0
        end

        # developerPayloadが正しいか
        # @raise エラー
        def validate_developer_payload!(receipt, error_msg)
          fail AndroidInvalidUserID, "#{error_msg} : Invalid developerPayload" unless receipt['developerPayload'] == id.to_s
        end

        # 定期購読のデータバリデーション
        # @param [Json] receipt purchase_dataのJSON
        def validate_payment_member_order!(receipt)
          subscription = get_subscription!(receipt['productId'], receipt['purchaseToken'])
          fail AndroidInvalidAutoRenewing, "Invalid autoRenewing" unless subscription.auto_renewing
          subscription
        end

        # Googleからsubscriptionを取得する
        # @raise エラー
        def get_subscription!(product_id, purchase_token)
          service = Google::Apis::AndroidpublisherV2::AndroidPublisherService.new
          service.get_purchase_subscription(
            Settings.android.package_name,
            product_id,
            purchase_token,
            options: {
              authorization: Signet::OAuth2::Client.new(
                token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
                scope: ['https://www.googleapis.com/auth/androidpublisher'],
                client_id: Settings.android.client_id,
                client_secret: Settings.android.client_secret,
                refresh_token: Settings.android.refresh_token
              )
            }
          )
        end
      end
    end
  end
end
