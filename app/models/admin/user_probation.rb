module Admin
  class UserProbation < ApplicationRecord
    belongs_to :user, class_name: '::User'
  end
end
