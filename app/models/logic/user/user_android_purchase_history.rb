# Androidレシートから購入履歴作成
require 'digest/md5'
module Logic
  module User
    module UserAndroidPurchaseHistory
      extend ActiveSupport::Concern

      # 購入履歴の追加を行う
      # @param [Hash] params APIリクエストパラメータ
      # @param [Json] receipt purchase_dataのJSON
      # @raise バリデーションエラー
      # @return 作成したレコード
      def create_android_purchase_history_by_request!(params, receipt)
        user_android_purchase_histories.create!(
          product_id_str: params[:product_id],
          order_id: receipt['orderId'],
          purchase_token: receipt['purchaseToken'],
          purchase_data: params[:purchase_data],
          signature: params[:signature]
        )
      end

      # 処理済みのデータが存在するか
      def exist_result_ok_history?(order_id)
        !user_android_purchase_histories.find_by(
          order_id: order_id,
          result_type: 0
        ).blank?
      end

      # リストア成功履歴の作成を行う
      # @param [Hash] params APIリクエストパラメータ
      # @raise バリデーションエラー
      # @return 作成したレコード
      def create_android_restore_result_history!(params, receipt)
        user_android_purchase_histories.create!(
          product_id_str: params[:product_id],
          order_id: receipt['orderId'],
          purchase_token: receipt['purchaseToken'],
          purchase_data: params[:purchase_data],
          signature: params[:signature],
          result_type: 'valid_ok',
          result_message: 'Restored'
        )
      end

      # 自動購読更新成功履歴の作成を行う
      # @param [Hash] params APIリクエストパラメータ
      # @raise バリデーションエラー
      # @return 作成したレコード
      def create_android_continue_result_history!(params, receipt)
        user_android_purchase_histories.create!(
          product_id_str: params[:product_id],
          order_id: receipt['orderId'],
          purchase_token: receipt['purchaseToken'],
          purchase_data: params[:purchase_data],
          signature: params[:signature],
          result_type: 'valid_ok',
          result_message: 'Continued'
        )
      end

      # 最新のsubscriptionのhistoryデータ取得
      def get_latest_subscription_history(purchase_token)
        !user_android_purchase_histories.where(
          product_id_str: ::PurchasePayingmember::PURCHASE_TYPE,
          purchase_token: purchase_token,
          result_type: 0
        ).maximum(:updated_at)
      end
    end
  end
end
