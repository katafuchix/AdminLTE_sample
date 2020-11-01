# 購入するときのバリデーション
# iOS, Android,web共通。バリデーションするだけ
module Logic
  module User
    module UserPayment
      module UserPaymentValidate
        extend ActiveSupport::Concern

        # 購入時バリデーション
        def validate_purchase!(params)
          validate_purchase_type!(params)
          if params[:type] == ::PurchasePayingmember::PURCHASE_TYPE
            validate_purchase_member!(params)
          else
            validate_purchase_point!(params)
          end
        end

        private

        # 購入タイプバリデーション
        def validate_purchase_type!(params)
          unless params[:type] == ::PurchasePayingmember::PURCHASE_TYPE || params[:type] == ::PurchasePoint::PURCHASE_TYPE
            fail InvalidPaymentType, I18n.t('api.errors.purchase.invalid_payment_type')
          end
        end

        # ポイント購入バリデーション
        def validate_purchase_point!(params)
          purchase = ::PurchasePoint.find_by(product_id_str: params[:product_id])
          fail InvalidProductId, I18n.t('api.errors.purchase.invalid_product_id') if purchase.blank?
          purchase
        end
      end
    end
  end
end
