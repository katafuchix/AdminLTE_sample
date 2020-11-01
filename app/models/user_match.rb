class UserMatch < ApplicationRecord
  include Validations::TargetValidation
  include Logic::UserMatch
  include UsersBelongsTo
  belongs_to_user
  has_many :user_relations, class_name: 'UserRelation', dependent: :destroy
  has_many :user_match_messages, class_name: 'UserMatchMessage', dependent: :destroy
  has_many :user_match_messages_desc, -> { order('created_at DESC, id DESC') }, dependent: :destroy, class_name: 'UserMatchMessage'
  validates :room_id, length: { minimum: 3, maximum: 100 }, uniqueness: true
  before_validation :generate_room_id
  scope :before_yesterday, -> (date) { where('created_at < ?', date.midnight) }

  before_create do
    self.message_last_updated_at = created_at
  end

  class << self
    def matchs_related_to_user(user)
      where('user_matches.user_id = ? OR user_matches.target_user_id = ?', user, user)
    end

    def unblocked_matchs(user)
      mutual_unblocked_ids = User.mutual_unblocked_users(user)
      matchs_related_to_user(user).where(target_user_id: mutual_unblocked_ids, user_id: mutual_unblocked_ids)
    end

    def not_outcomming_display_matchs(user)
      user_ids = user.outcomming_display_users.without_soft_destroyed.ids
      matchs_related_to_user(user).where.not(target_user_id: user_ids, user_id: user_ids)
    end
  end
end
