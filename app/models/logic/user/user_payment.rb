# 購入処理
# 男女別
module Logic
  module User
    module UserPayment
      extend ActiveSupport::Concern
      include UserPaymentStatus
      include UserPaymentValidate
      include UserPaymentIos
      include UserPaymentAndroid
      include UserPaymentMail
      include UserPaymentBonus

      # ここに例外クラスを追加したら
      # models/user_ios_purchase_historyとmodels/user_android_purchase_historyのresult_typeにunderscoreの形式で追加してください
      class InvalidProductId < StandardError
      end
      class InvalidPaymentType < StandardError
      end
      class InvalidCharging < StandardError
      end
      class InvalidPoint < StandardError
      end
      class InvalidReceipt < StandardError
      end
      class InvalidUserAgeCertification < StandardError
      end
      class InvalidTransaction < StandardError
      end
      class AppleServerConnectionError < StandardError
      end
      class AndroidServerConnectionError < StandardError
      end
      class AndroidInvalidUserID < StandardError
      end
      class AndroidInvalidAutoRenewing < StandardError
      end
      class InvalidUsedReceipt < StandardError
      end
      class InvalidPremium < StandardError
      end

      included do
        INVALID_EXCEPTIONS = [
          InvalidProductId, InvalidPaymentType,
          InvalidCharging, InvalidPoint,
          InvalidReceipt, InvalidUserAgeCertification, InvalidTransaction,
          AppleServerConnectionError,
          AndroidServerConnectionError, AndroidInvalidUserID, AndroidInvalidAutoRenewing,
          InvalidUsedReceipt
        ].freeze
      end

      # 購入処理(Web版)
      # @param [Model] purchase 購入マスタ(PurchasePayingmember / PurchasePoint)
      # @param [Boolean] skip_stil_paying_validation 会員購入済みバリデーションをスキップするか(自動購読バッチ用)
      # 購入履歴に関しては上位の箇所で処理する(共通化出来ないし、stripeの各種オブジェクトが必要)
      def process_purchase!(purchase, skip_stil_paying_validation = false)
        params = { product_id: purchase.product_id_str, type: purchase.class::PURCHASE_TYPE, skip_stil_paying_validation: skip_stil_paying_validation }
        validate_purchase_type!(params)
        if params[:type] == ::PurchasePayingmember::PURCHASE_TYPE
          # 会員購入
          purchase_member!(params)
        else
          # ポイント購入
          purchase_point!(params)
        end
      end

      private

      # ポイント購入
      def purchase_point!(params)
        purchase = validate_purchase_point!(params)
        add_point!(purchase.point)
        PurchaseMailer.purchase_point(self).deliver_later if sendable_notification_mail?
        SlackService.charged(self, purchase)
      end

      # 購入トランザクション
      def purchase_transaction!(history)
        transaction do
          yield if block_given?
        end
      rescue *INVALID_EXCEPTIONS => e
        result_type = e.class.to_s.split('::').last.underscore
        history.update!(result_type: result_type, result_message: e.message)
        raise e
      end

      # 会員処理(Web版または管理画面から実行した場合)
      # @return [Integer] 会員レコード
      def apply_payment!(term, type, product_id = nil)
        created_payment = nil
        if new_payment?(type)
          # 新規登録
          created_payment = become_payingmember!(term, type)
          send_payingmember_mail(type == 'premium_charging')
        else
          # 継続
          created_payment = continue_payingmember!(term, type)
        end
        # ボーナス付与
        payment_bonus(product_id) if product_id
        created_payment
      end

      # 会員新規登録か
      def new_payment?(type)
        charging_payment(type).blank?
      end

      # 会員新規登録
      def become_payingmember!(term, type)
        # startとendの期間を更新
        start_at = Time.current
        return false if type == 'premium_charging' && !normal_charging_member? && sex == 'male'
        user_payments.create!(start_at: start_at, end_at: start_at + term, payment_type: type)
      end

      # 会員継続
      def continue_payingmember!(term, type)
        # 期限終了時から契約開始
        start_at = charging_payment(type).end_at
        user_payments.create!(start_at: start_at, end_at: start_at + term, payment_type: type)
      end

      # Enum -> Time変換
      def paying_term(term_enum)
        term = nil
        if term_enum =~ /\Amonth.*/
          term = term_enum.gsub(/month/, '').to_i.months
        elsif term_enum =~ /\Ayear.*/
          term = term_enum.gsub(/year/, '').to_i.years
        end
        term
      end

      # ミリ秒 -> 日付変換
      def calc_expire_date(expires_date_ms)
        return nil if expires_date_ms.blank?
        Time.at(expires_date_ms.to_i / 1000)
      end

      # user_paymentsレコードの期間から現在契約中の有料会員のレコードを取得
      def normal_charging_payment
        user_payments.detect do |p|
          p.payment_type == 'normal_charging' && p.start_at <= Time.current && p.end_at >= Time.current
        end
      end

      # user_paymentsレコードの期間から現在契約中のプレミアム会員のレコードを取得
      def premium_charging_payment
        user_payments.detect do |p|
          p.payment_type == 'premium_charging' && p.start_at <= Time.current && p.end_at >= Time.current
        end
      end

      # payment_typeから現在契約中のレコードを取得
      def charging_payment(type)
        type == 'normal_charging' ? normal_charging_payment : premium_charging_payment
      end
    end
  end
end
