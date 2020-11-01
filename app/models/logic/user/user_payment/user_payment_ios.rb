module Logic
  module User
    module UserPayment
      module UserPaymentIos
        extend ActiveSupport::Concern

        include UserPaymentIosValidates
        include UserIosPurchaseHistory
        include UserPaymentBonus

        # APIのリクエストにより購入処理を行う(iOS)
        # @param [Hash] params APIリクエストパラメータ
        # @raise 購入時例外
        def ios_purchase!(params)
          # 購入履歴を作成
          history = create_purchase_history_by_request!(params)
          purchase_transaction!(history) do
            # レシートの検証
            validate_inapp_receipt!(params)
            # 処理前のバリデーション
            validate_purchase!(params)
            transaction = latest_transaction
            # 購入情報の反映
            process_ios_purchase!(params.merge(transaction: transaction))
            # 複数アカウントをもつ場合他のユーザーの履歴をskipする
            skip_other_user_histories!(transaction.try(:fetch, 'original_transaction_id', nil))
            # 購入履歴に処理結果を追加
            history.update!(result_type: 'valid_ok',
                            transaction_id: transaction.try(:fetch, 'transaction_id', nil),
                            original_transaction_id: transaction.try(:fetch, 'original_transaction_id', nil))
          end
        end

        # 購入処理
        def process_ios_purchase!(params)
          validate_purchase_type!(params)
          params[:type] == ::PurchasePayingmember::PURCHASE_TYPE ? ios_purchase_member!(params) : purchase_point!(params)
        end

        # APIのリクエストによりレシートから復旧処理を行う(iOS)
        # @param [Hash] params APIリクエストパラメータ
        # @raise 購入時例外
        def restore_ios_purchase!(params)
          @purchase_restoring = true
          transaction do
            validate_inapp_receipt!(params)
            process_restore!(params)
          end
        end

        # レシートから会員の継続処理を行う(iOS、主にバッチ用)
        # @param [Hash] params レシートを含むパラメータ
        # @raise 購入時例外
        def subscript_ios_purchase!(params)
          @purchase_restoring = true
          transaction do
            validate_inapp_receipt!(params)
            return process_subscription_by_latest_receipt_info!(params)
          end
          false
        end

        private

        # iOSのレシートを元にした会員変更処理
        def apply_payment_by_receipt!(type, transaction)
          result = create_payingmember_by_receipt!(type, transaction)
          if result
            unless purchase_restoring?
              # 新規登録の場合はメール送信
              is_premium = PurchasePayingmember.judge_premium_payment(transaction['product_id'])
              send_payingmember_mail(is_premium)
            end
            # ボーナス付与
            payment_bonus(transaction['product_id'])
          end
          result
        end

        # リストア処理(アプリの購入情報がサーバに反映されてない場合に使用)
        def process_restore!(params)
          if @in_app.present?
            histories = histories_by_in_app
            @in_app.each do |app|
              ot_count = @in_app.count { |a| a['original_transaction_id'] == app['original_transaction_id'] }
              if single_unpayment_receipt?(app, ot_count, histories) || subscript_unpayment_receipt?(app, ot_count, histories) || multiple_accounts_have_payment_receipt?(app, ot_count, histories)
                destory_histroy_if_existed!(app)
                process_each_restore!(params, app)
              end
            end
          end
        end

        # レシートのlatest_receipt_infoを使用して会員継続処理
        def process_subscription_by_latest_receipt_info!(params)
          return false if @latest_receipt_info.blank?
          # 購入履歴と突き合わせて、既に処理済みのデータは除外する
          lris = @latest_receipt_info.reject do |app|
            !PurchasePayingmember.judge_member_payment(app['product_id']) ||
              user_ios_purchase_histories.detect do |d|
                d.product_id_str == app['product_id'] &&
                  d.transaction_id == app['transaction_id'].to_i
              end
          end
          return false if lris.blank?
          lris.each do |app|
            process_each_restore!(params, app)
          end
          true
        end

        # 会員レコード登録
        # start_at => 現在時刻  end_at => レシートの期限日時
        def create_payingmember_by_receipt!(type, transaction)
          # startとendの期間を更新
          # それぞれレシートの購入日と有効期限日をセットする
          start_at = calc_expire_date(transaction['purchase_date_ms'])
          end_at = calc_expire_date(transaction['expires_date_ms'])
          return false if Rails.env.production? && start_at > end_at # 本番では日付が逆転している場合は登録なし。本番以外は検証用のため登録。
          return false if type == 'premium_charging' && !normal_charging_member? && sex == 'male'
          user_payments.create!(start_at: start_at, end_at: end_at, payment_type: type)
          true
        end

        # レシートのin_appまたはlatest_receipt_infoの配列要素毎の処理
        def process_each_restore!(params, app)
          original_transaction_id = app['original_transaction_id']
          product_id = app['product_id']
          merged_params = params.merge(product_id: product_id, transaction: app, transaction_id: app['transaction_id'],
                                       original_transaction_id: original_transaction_id, skip_stil_paying_validation: true)
          if PurchasePayingmember.judge_member_payment(app['product_id'])
            ios_purchase_member!(merged_params)
          else
            purchase_point!(merged_params)
          end
          create_restore_result_history!(merged_params)
        end

        def histories_by_in_app
          ::UserIosPurchaseHistory.where(@in_app.map do |a|
            "(product_id_str = '#{a['product_id']}' AND transaction_id = #{a['transaction_id']})"
          end.join(' OR '))
        end

        # 自分の履歴のみ削除するようにする
        def destory_histroy_if_existed!(app)
          ::UserIosPurchaseHistory.where(user_id: id, product_id_str: app['product_id'], transaction_id: app['transaction_id']).destroy_all
        end

        def latest_transaction
          return nil if @in_app.blank?
          @in_app.max_by { |r| r['transaction_id'] }
        end

        # リストア処理か
        def purchase_restoring?
          !@purchase_restoring.nil? && @purchase_restoring
        end
      end
    end
  end
end
