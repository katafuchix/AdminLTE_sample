module Admin
  class User < ApplicationRecord
    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :validatable
    enum role: %w(operator admin special)

    validates :name, presence: true, uniqueness: true
    has_one :user_notify, dependent: :destroy, class_name: 'Admin::UserNotify'
    after_create :create_user_notify, unless: proc { |admin_user| admin_user.user_notify }

    include ::Logic::Admin::User
  end
end
