class PurchasePayingmemberCampaign < ApplicationRecord
  belongs_to :purchase_payingmember
  enum campaign_type: %w(pater_point relation_point)
  enum sex: %w(male female both)
  enum contact_type: %w(new_or_continue new_only continue_only)
  validates :purchase_payingmember_id, presence: true
  validates :campaign_type, presence: true
  validates :value, presence: true, length: { minimum: 0 }
  validates :start_at, presence: true
  validates :end_at, presence: true
end
