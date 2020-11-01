module Admin
  class UserNotify < ApplicationRecord
    NOTIFY_COLUMN = %i(
      user_certification_notify
      profile_image_notify
      user_profile_notify
      inquiry_notify
    ).freeze

    belongs_to :user, class_name: 'Admin::User'
    NOTIFY_COLUMN.each { |col_name| validates col_name, inclusion: { in: [true, false] } }
  end
end
