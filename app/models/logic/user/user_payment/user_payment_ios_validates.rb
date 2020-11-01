module Logic
  module User
    module UserPayment
      module UserPaymentIosValidates
        extend ActiveSupport::Concern

        private

        # InAppPurchaseレシートの検証
        # @param [Hash] params auth_token、product_id、base64形式レシート等を含むパラメーター
        # :nocov:
        def validate_inapp_receipt!(params)
          # TODO: Appleの検証仕様が変わった場合修正
          data = params[:base64_receipt_data]
          # base64のレシートをAppleに送信
          receipt = Venice::Receipt.verify(data, shared_secret: Settings.itunes_connect_shared_secret)
          validate_receipt_process(receipt, params)
        end

        # レシートの検証
        # @param [Hash] receipt レシート検証結果
        # @param [Hash] params auth_token、product_id、base64形式レシート等を含むパラメーター
        # @raise エラー
        def validate_receipt_process(receipt, params)
          error_msg = I18n.t('api.errors.purchase.invalid_receipt')
          validate_receipt!(receipt, error_msg)
          validate_status!(receipt, error_msg)
          validate_receipt_hash!(receipt, error_msg)
          validate_receipt_in_app_hash!(error_msg)
          validate_receipt_product_id!(params, error_msg)
        end

        # レシート情報があるか
        # @raise エラー
        def validate_receipt!(receipt, error_msg)
          fail InvalidReceipt, "#{error_msg} : Venice::Receipt receipt not found" if receipt.blank?
        end

        # レシートのステータスが正しいか
        # 参考(https://developer.apple.com/jp/documentation/General/ValidateAppStoreReceipt/Chapters/ValidateRemotely.html)
        # @raise エラー
        def validate_status!(receipt, error_msg)
          status = receipt.original_json_response['status'].to_i
          fail AppleServerConnectionError, 'Apple server connection error' if status == 21_005
          fail InvalidReceipt, "#{error_msg} : status not 0" unless status == 0
        end

        # 「receipt」ハッシュの取得
        # @raise エラー
        def validate_receipt_hash!(receipt, error_msg)
          @receipt_data = receipt.original_json_response['receipt']
          fail InvalidReceipt, "#{error_msg} : receipt data not found" if @receipt_data.blank?
        end

        # 「in_app」、「latest_receipt_info」ハッシュの取得
        # 「latest_receipt_info」は継続課金以外の時はセットされない場合がある
        # @raise エラー
        def validate_receipt_in_app_hash!(error_msg)
          @in_app = @receipt_data['in_app']
          @latest_receipt_info = @receipt_data['original_json_response']['latest_receipt_info']
          fail InvalidReceipt, "#{error_msg} : in_app data not found" if @in_app.blank?
        end

        # paramsのproduct_idがin_appに存在するか
        # @raise エラー
        def validate_receipt_product_id!(params, error_msg)
          return if params[:product_id].blank?
          found_product_id = @in_app.detect { |a| a['product_id'] == params[:product_id] }
          fail InvalidReceipt, "#{error_msg} : invalid product_id" unless found_product_id
        end

        # :nocov:

        # 通常購入(課金継続以外)かつまだサーバ側で処理していないデータか
        def single_unpayment_receipt?(app, ot_count, histories)
          # in_app内に同じoriginal_transaction_idが複数存在しない場合に通常購入と判定する
          return false unless ot_count == 1
          # user_ios_purchase_historiesレコードのproduct_idとtransaction_idで未処理か判定する
          history = histories.find_by(product_id_str: app['product_id'], transaction_id: app['transaction_id'])
          # user_ios_purchase_historiesレコードがない、または通信エラーで処理できなかった場合は処理の対象にする
          if history.blank? || history.result_type == 'apple_server_connection_error'
            return true
          end
          false
        end

        # 課金継続の未処理データか
        def subscript_unpayment_receipt?(app, ot_count, histories)
          # in_app内に同じoriginal_transaction_idが複数存在する場合に継続購入と判定する
          return false unless ot_count > 1
          original_transactions = user_ios_purchase_histories.where(original_transaction_id: app['original_transaction_id'])
          if original_transactions.present? # ※1端末で複数会員使用している場合は対応できないので注意
            # user_ios_purchase_historiesレコードのproduct_idとtransaction_idで未処理か判定する
            history = histories.find_by(product_id_str: app['product_id'], transaction_id: app['transaction_id'])
            # user_ios_purchase_historiesレコードがない、または通信エラーで処理できなかった場合は処理の対象にする
            if history.blank? || history.result_type == 'apple_server_connection_error'
              return true
            end
          end
          false
        end

        # 同じApple IDで複数のアカウントを持つか
        def multiple_accounts_have_payment_receipt?(app, ot_count, histories)
          return false unless ot_count >= 1
          return false if histories.where(user_id: id, product_id_str: app['product_id'], transaction_id: app['transaction_id']).present?
          # 同じApple IDの他のユーザーの履歴
          history = histories.where.not(user_id: id).find_by(product_id_str: app['product_id'], original_transaction_id: app['original_transaction_id'])
          return true if history.present?
          false
        end

        # レシートのtransactionデータバリデーション
        def validate_payment_member_transaction!(transaction)
          if transaction.blank? ||
             transaction['expires_date_ms'].blank? ||
             exist_transaction_history?(transaction['transaction_id'])
            fail InvalidTransaction, I18n.t('api.errors.purchase.invalid_payment_member_transaction')
          end
        end
      end
    end
  end
end
