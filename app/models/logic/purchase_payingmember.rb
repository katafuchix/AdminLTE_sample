module Logic
  module PurchasePayingmember
    extend ActiveSupport::Concern

    def self.judge_member_payment(product_id)
      ::PurchasePayingmember.find_by(product_id_str: product_id).present?
    end

    def self.judge_premium_payment(product_id)
      purchase = ::PurchasePayingmember.find_by(product_id_str: product_id)
      purchase.present? && purchase.is_premium
    end
  end
end
