class UserRelation < ApplicationRecord
  include Logic::UserRelation
  include Validations::TargetValidation
  include UsersBelongsTo
  include Approvable
  approvable :message
  belongs_to_user
  belongs_to :user_match, class_name: 'UserMatch', required: false, dependent: :destroy
  attr_accessor :skip_use_relation_point
  attr_accessor :skip_notification
  validates :message, length: { minimum: 0, maximum: 200 }, allow_blank: true
  validates :read, inclusion: { in: [true, false] }
  validate :validate_relation_point, on: :create, unless: :skip_use_point?
  validate :validate_relation_message_point, on: :create, unless: :skip_use_point?
  before_validation do
    self.message_status ||= 'blanked'
  end
  before_create do
    self.active = message.blank?
  end
  before_create :use_relation_point!, unless: :skip_use_point?
  before_create :use_relation_message_point!, unless: :skip_use_point?
  after_create :destroy_pickup, if: :find_pickup
  after_save :send_relation_notification, unless: :user_match_id_changed?
  after_save :matching_if_need, unless: :user_match_id_changed?

  #scope :relation_messages_related_to_user_match_id, -> (id) { where(user_match_id: id, message_status: 'accepted') }
  #scope :order_created_at, -> { order(:created_at) }
end
