class UserTemplate < ApplicationRecord
  has_many :user_profiles, foreign_key: :user_template_id
  mount_uploader :background_image, BackgroundImageUploader
  validates :name, presence: true
end
