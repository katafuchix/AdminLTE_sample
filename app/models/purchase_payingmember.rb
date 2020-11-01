class PurchasePayingmember < ApplicationRecord
  PURCHASE_TYPE = 'paying_member'.freeze
  has_many :user_purchase_histories, as: :purchase
  has_many :purchase_payingmember_campaigns
  has_many :opening_purchase_payingmember_campaigns,
           -> { where(enabled: true).where('start_at <= :current AND end_at >= :current', current: Time.current) },
           class_name: 'PurchasePayingmemberCampaign'
  include Logic::PurchasePayingmember
  validates :name, presence: true, allow_blank: false
  validates :product_id_str, presence: true, allow_blank: false
  validates :price, presence: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0
  }
  validates :term, presence: true
  validates :is_premium, inclusion: [true, false]
  validates :sort_order, presence: true, numericality: {
    only_integer: true
  }
  enum term: %w(month1 month3 month6 month12)
end
