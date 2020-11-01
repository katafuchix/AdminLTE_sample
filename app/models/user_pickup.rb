class UserPickup < ApplicationRecord
  include Validations::TargetValidation
  include UsersBelongsTo
  belongs_to_user
end
