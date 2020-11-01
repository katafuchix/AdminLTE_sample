# == Schema Information
#
# Table name: masters
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  enabled    :boolean
#  sort_order :integer
#  type       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Master
  class Prefecture < Master
    has_many :user_profiles, foreign_key: :prof_birth_place_id
    has_many :user_profiles, foreign_key: :prof_address_id
  end
end
