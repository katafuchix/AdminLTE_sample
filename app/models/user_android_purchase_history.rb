class UserAndroidPurchaseHistory < ApplicationRecord
  default_scope -> { where(skip: false) }
  belongs_to :user
  validates :product_id_str, presence: true
  validates :purchase_data, presence: true
  validates :signature, presence: true
  enum result_type: %w(
    valid_ok
    invalid_product_id
    invalid_payment_type
    invalid_charging
    invalid_point
    invalid_receipt
    invalid_user_age_certification
    invalid_transaction
    apple_server_connection_error
    android_server_connection_error
    android_invalid_user_id
    android_invalid_auto_renewing
    invalid_premium
    invalid_other
  )
end
