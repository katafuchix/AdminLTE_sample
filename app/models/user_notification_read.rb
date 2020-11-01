class UserNotificationRead < ApplicationRecord
  belongs_to :notificatable, polymorphic: true
end
