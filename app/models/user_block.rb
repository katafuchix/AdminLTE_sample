class UserBlock < ApplicationRecord
  include Validations::TargetValidation
  include UsersBelongsTo
  belongs_to_user

  scope :not_forced, -> { where(is_forced: false) }
end
