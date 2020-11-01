class UserMemo < ApplicationRecord
  include Validations::TargetValidation
  belongs_to :user
  belongs_to :target_user, class_name: 'User'

  validates_uniqueness_of :target_user_id, scope: :user_id
  validates :body, length: { minimum: 0, maximum: 1000 }, allow_blank: true
end
