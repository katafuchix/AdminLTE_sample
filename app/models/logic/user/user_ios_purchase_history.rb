# iOSレシートから購入履歴作成
require 'digest/md5'
module Logic
  module User
    module UserIosPurchaseHistory
      extend ActiveSupport::Concern

      # 購入履歴の追加を行う
      # @param [Hash] params APIリクエストパラメータ
      # @raise バリデーションエラー
      # @return 作成したレコード
      def create_purchase_history_by_request!(params)
        user_ios_purchase_histories.create!(
          product_id_str: params[:product_id],
          base64_receipt: params[:base64_receipt_data]
        )
      end

      # 購読更新処理成功履歴の作成を行う
      # @param [Hash] params APIリクエストパラメータ
      # @raise バリデーションエラー
      # @return 作成したレコード
      def create_restore_result_history!(params)
        skip_other_user_histories!(params['original_transaction_id'])
        user_ios_purchase_histories.create!(
          product_id_str:  params[:product_id],
          transaction_id: params[:transaction_id],
          base64_receipt: "[Restored:#{params[:transaction_id]}]#{params[:base64_receipt_data]}",
          result_type: 'valid_ok',
          original_transaction_id: params[:original_transaction_id]
        )
      end

      # 他のユーザーが同じoriginal_transaction_idをもつ履歴があれば削除する
      def skip_other_user_histories!(original_transaction_id)
        return if original_transaction_id.blank?
        old_history_user_ids = ::UserIosPurchaseHistory.where(original_transaction_id: original_transaction_id).pluck(:user_id)
        ::UserIosPurchaseHistory.where(user_id: old_history_user_ids).where.not(user_id: id).update_all(skip: true) if old_history_user_ids
      end

      # TransactionIDの履歴が存在するか
      # @param [Integer] transaction_id TransactionId
      # @return [Boolean] 判定結果
      def exist_transaction_history?(transaction_id)
        user_ios_purchase_histories.find_by(transaction_id: transaction_id).present?
      end

      # OriginalTransactionIDの一覧を取得
      # @param [Integer] ori_transaction_id OriginalTransactionID
      # @return [Array] 一覧
      def original_transaction_histories(ori_transaction_id)
        user_ios_purchase_histories.where(original_transaction_id: ori_transaction_id)
      end
    end
  end
end
