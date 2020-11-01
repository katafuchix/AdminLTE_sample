class UserInviteCode < ApplicationRecord
  belongs_to :user
  validates :invite_code, presence: true
  validate :validate_invite_user_unique
  before_update :do_used
  with_options on: [:update] do |user_invite_code|
    user_invite_code.validate :validate_invited_user
  end

  # 招待コードを更新
  def update_invite_code!
    generate_invite_code
    save!
  end

  private

  def do_used
    self.used = invited_user_id.present?
  end

  def validate_invited_user
    if invited_user_id.present?
      # 既に使用済み or 自分自身の招待はNG
      errors[:base] << I18n.t('api.errors.invite.used_code') if used
      if user_id == invited_user_id
        errors[:base] << I18n.t('api.errors.invite.self_code')
      end
    end
  end

  def validate_invite_user_unique
    if invited_user_id.present? && UserInviteCode.find_by(invited_user_id: invited_user_id).present?
      errors[:base] << I18n.t('api.errors.invite.still_rewarded')
    end
  end
end
