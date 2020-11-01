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
  class RequestUntilMeet < Master
    has_many :user_profiles, foreign_key: :prof_request_until_meet_id
  end
end
