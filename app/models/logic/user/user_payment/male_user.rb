# 男性の購入処理
# 会員購入済か判定
module Logic
  module User
    module UserPayment
      module MaleUser
        extend ActiveSupport::Concern

        # 既に会員購入済みか判定
        # @return [Boolean] 判定結果
        def still_paying_member?(params, purchase)
          return false if params[:skip_stil_paying_validation].present?
          (normal_charging_member? && !purchase.is_premium) || (premium_charging_member? && purchase.is_premium)
        end

        private

        # 会員購入バリデーション
        def validate_purchase_member!(params)
          fail InvalidUserAgeCertification, I18n.t('api.errors.purchase.not_age_certified') unless age_pending_or_certified?
          purchase = ::PurchasePayingmember.find_by(product_id_str: params[:product_id])
          fail InvalidProductId, I18n.t('api.errors.purchase.invalid_product_id') if purchase.blank?
          fail InvalidPremium, I18n.t('api.errors.purchase.invalid_premium') if purchase.is_premium && !normal_charging_member?
          fail InvalidPremium, I18n.t('purchases.still_member') if still_paying_member?(params, purchase)
          purchase
        end

        # Web版 / 管理画面からの会員購入
        # @return [Integer] 会員購入ID
        def purchase_member!(params)
          purchase = validate_purchase_member!(params)
          result = apply_payment!(paying_term(purchase.term), purchase.is_premium ? 'premium_charging' : 'normal_charging', purchase.product_id_str)
          SlackService.charged(self, purchase) if result
          result
        end

        # iOSからの会員購入
        def ios_purchase_member!(params)
          validate_payment_member_transaction!(params[:transaction])
          purchase = validate_purchase_member!(params)
          result = apply_payment_by_receipt!(purchase.is_premium ? 'premium_charging' : 'normal_charging', params[:transaction])
          SlackService.charged(self, purchase) if result
        end

        # Androidからの会員購入
        def android_purchase_member!(params, receipt)
          subscription = validate_payment_member_order!(receipt)
          purchase = validate_purchase_member!(params)
          result = apply_payment_by_subscription!(purchase.is_premium ? 'premium_charging' : 'normal_charging', receipt['productId'], subscription)
          SlackService.charged(self, purchase) if result
        end
      end
    end
  end
end
