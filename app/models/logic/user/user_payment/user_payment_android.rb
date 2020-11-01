module Logic
  module User
    module UserPayment
      module UserPaymentAndroid
        extend ActiveSupport::Concern

        include UserPaymentAndroidValidates
        include UserAndroidPurchaseHistory
        include UserPaymentBonus

        # TODO: 購入後48時間以内はユーザーからキャンセルできるからバッチなりなんなりでチェックしなきゃいけない

        # APIのリクエストにより購入処理を行う(Android)
        # @param [Hash] params APIリクエストパラメータ
        # @raise 購入時例外
        def android_purchase!(params)
          receipt = JSON.parse(params[:purchase_data])

          # 購入履歴を作成
          history = create_android_purchase_history_by_request!(params, receipt)
          purchase_transaction!(history) do
            # レシートの検証
            validate_android_receipt!(params, receipt)
            # 処理前のバリデーション
            validate_purchase!(params)
            # 購入情報の反映
            process_android_purchase!(params, receipt)
            # 購入履歴に処理結果を追加
            history.update!(result_type: 'valid_ok')
          end
        end

        # 購入処理
        def process_android_purchase!(params, receipt)
          validate_purchase_type!(params)
          params[:type] == ::PurchasePayingmember::PURCHASE_TYPE ? android_purchase_member!(params, receipt) : purchase_point!(params)
        end

        # APIのリクエストによりレシートから復旧処理を行う(Android)
        # 購入情報が来るだけなので、処理に失敗した履歴があればそれを復旧。
        # 重複チェック等では自ユーザーのデータしか取れないので、別会員が同端末でリストアした場合も問題なし。
        # @param [Hash] params APIリクエストパラメータ
        # @raise 購入時例外
        def restore_android_purchase!(params)
          @purchase_restoring = true
          receipt = JSON.parse(params[:purchase_data])
          merged_params = params.merge(
            product_id: receipt['productId'],
            type: PurchasePayingmember.judge_member_payment(receipt['productId']) ? ::PurchasePayingmember::PURCHASE_TYPE : ::PurchasePoint::PURCHASE_TYPE
          )
          transaction do
            # レシートの検証
            validate_android_receipt!(merged_params, receipt)
            # 処理前のバリデーション
            validate_purchase!(merged_params)
            # 購入情報の反映
            process_android_purchase!(merged_params, receipt)
            # リストア履歴の追加
            create_android_restore_result_history!(merged_params, receipt)
          end
        end

        # レシートから会員の継続処理を行う(Android、主にバッチ用)
        # @param [String] purchase_token purchase_token。
        # @raise 購入時例外
        def subscript_android_purchase!(purchase_token)
          # リストアじゃないんだけどな
          @purchase_restoring = true
          transaction do
            # 最新の定期購読履歴を取得。履歴がないはずはない。
            latest_history = get_latest_subscription_history(purchase_token)
            return if latest_history.blank?
            # Googleからsubscriptionを取得。キャンセルしない限りpurchase_tokenは変わらない。autoRenewingがfalse→解約された。
            subscription = get_subscription!(latest_history[:product_id_str], purchase_token)
            return unless subscription.autoRenewing

            # 同じuser_paymentsがあったらskip
            start_at = calc_expire_date(subscription.start_time_millis)
            end_at = calc_expire_date(subscription.expiry_time_millis)
            return unless user_payments.find_by(start_at: start_at, end_at: end_at).blank?

            # リストアのときはdeveloper_payload見ちゃだめだ
            # subscriptionからorder_id/payment_stateが取れる。。
            params = {
              product_id: latest_history[:product_id_str],
              purchase_data: latest_history[:purchase_data],
              signature: latest_history[:signature]
            }
            receipt = {
              order_id: subscription.order_id,
              purchase_token: purchase_token
            }

            # 購入情報反映
            process_android_purchase!(params, receipt)
            # 継続履歴の追加
            create_android_continue_result_history!(params, receipt)
          end
          false
        end

        private

        # リストア処理か
        def purchase_restoring?
          !@purchase_restoring.nil? && @purchase_restoring
        end

        # Androidのsubscriptionを元にした会員変更処理
        def apply_payment_by_subscription!(type, product_id, subscription)
          result = create_payingmember_by_subscription!(type, subscription)
          if result
            unless purchase_restoring?
              # 新規登録の場合はメール送信
              is_premium = PurchasePayingmember.judge_premium_payment(product_id)
              send_payingmember_mail(is_premium)
            end
            # ボーナス付与
            payment_bonus(product_id)
          end
        end

        # 会員レコード登録
        # start_at => 現在時刻  end_at => subscriptionの期限日時
        def create_payingmember_by_subscription!(type, subscription)
          # startとendの期間を更新
          # それぞれsubscriptionの購入日と有効期限日をセットする
          start_at = calc_expire_date(subscription.start_time_millis)
          end_at = calc_expire_date(subscription.expiry_time_millis)
          return false if Rails.env.production? && start_at > end_at # 本番では日付が逆転している場合は登録なし。本番以外は検証用のため登録。
          return false if type == 'premium_charging' && !normal_charging_member? && sex == 'male'
          user_payments.create!(start_at: start_at, end_at: end_at, payment_type: type)
          true
        end
      end
    end
  end
end
