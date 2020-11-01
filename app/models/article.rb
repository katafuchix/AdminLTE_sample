class Article < ApplicationRecord
  belongs_to :user

  validates :body, length: { minimum: 3, maximum: 200 }, allow_blank: true

end
