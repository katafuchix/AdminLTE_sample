class UserBilling < ApplicationRecord
  belongs_to :user
  with_options on: :update do |user_billing|
    user_billing.validates :address, presence: true
    user_billing.validates :name, presence: true
    user_billing.validates :tel, presence: true
  end
  # xxx-xxxx-xxxx or 11桁の数字
  validates :tel, allow_blank: true, format: { with: /\A0[7-9]0-?\d{4}-?\d{4}\z/ }
  include Logic::UserBilling
end
