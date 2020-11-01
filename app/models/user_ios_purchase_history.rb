class UserIosPurchaseHistory < ApplicationRecord
  default_scope -> { where(skip: false) }
  belongs_to :user
  validates :product_id_str, presence: true
  validates :base64_receipt, presence: true
  validates :user_id, uniqueness: { scope: [:transaction_id], message: I18n.t('activerecord.errors.user_ios_purchase_history.invalid_used_receipt') }
  enum result_type: %w(
    valid_ok
    invalid_product_id
    invalid_charging
    invalid_point
    invalid_receipt
    invalid_payment_type
    invalid_other
    invalid_user_age_certification
    apple_server_connection_error
    invalid_transaction
    invalid_premium
  )
end
