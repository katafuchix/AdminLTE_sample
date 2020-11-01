class PurchasePoint < ApplicationRecord
  PURCHASE_TYPE = 'point'.freeze
  has_many :user_purchase_histories, as: :purchase
  validates :name, presence: true, allow_blank: false
  validates :product_id_str, presence: true, allow_blank: false
  validates :point, presence: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0
  }
  validates :price, presence: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0
  }
  validates :sort_order, presence: true, numericality: {
    only_integer: true
  }
end
