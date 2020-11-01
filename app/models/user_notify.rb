class UserNotify < ApplicationRecord
  NOTIFY_COLUMN = %i(
    match_push_notify
    relation_push_notify
    match_message_push_notify
    notification_push_notify
    match_mail_notify
    relation_mail_notify
    match_message_mail_notify
    notification_mail_notify
    visitor_push_notify
    visitor_mail_notify
  ).freeze

  belongs_to :user
  NOTIFY_COLUMN.each { |col_name| validates col_name, inclusion: { in: [true, false] } }
end
