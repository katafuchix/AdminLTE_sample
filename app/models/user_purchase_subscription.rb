class UserPurchaseSubscription < ApplicationRecord
  belongs_to :user, optional: true
  has_one :user_purchase_history
  has_one :purchase_payingmember, primary_key: :product_id_str, foreign_key: :product_id_str
end
