class UserViolation < ApplicationRecord
  include Validations::TargetValidation
  include UsersBelongsTo
  include Approvable
  approvable :reason
  belongs_to_user
  belongs_to :violation_category, class_name: Master::ViolationCategory

  after_create :send_notification_on_slack

  validates :reason, length: { minimum: 0, maximum: 1000 }, allow_blank: true

  private

  def send_notification_on_slack
    SlackService.violation_notify_to_cs_channel(
      I18n.t('activerecord.models.user_violation'), violation_category.name
    )
  end
end
