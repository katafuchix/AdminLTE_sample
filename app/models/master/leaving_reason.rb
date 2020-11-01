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
  class LeavingReason < Master
    has_many :inquiry_leaving_reasons
    has_many :inquiries, through: :inquiry_leaving_reasons

    validates :name, length: { minimum: 1, maximum: 50 }
  end
end
