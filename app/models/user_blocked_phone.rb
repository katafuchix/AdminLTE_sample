class UserBlockedPhone < ApplicationRecord
  belongs_to :user
  validates :user, presence: true
  validates :phone_number, presence: true, format: { with: /\A0[6-9]0\d{8}\z/ }
  before_validation :check_user_already_registered_phone_number
  before_validation :check_whether_not_self_phone_number

  private

  def check_user_already_registered_phone_number
    return unless user.user_blocked_phones.find_by(phone_number: phone_number).present?
    errors.add(:phone_number, I18n.t('errors.messages.taken'))
  end

  def check_whether_not_self_phone_number
    return unless user.mobile_phone == phone_number || user.unconfirmed_mobile_phone == phone_number
    fail StandardError, I18n.t('activerecord.errors.messages.unable_to_block_self_phone_number')
  end
end
