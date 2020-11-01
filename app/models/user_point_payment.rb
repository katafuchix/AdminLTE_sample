class UserPointPayment < ApplicationRecord
  belongs_to :user
  delegate :user_profile, to: :user
  validates :process_type, presence: true
  validates :point, presence: true
  validates :process_date, presence: true
  validates :end_at, presence: true, if: :added_process_type?
  validates :remain_point, presence: true, if: :added_process_type?
  enum process_type: %w(added used)
  enum point_type: %w(purchase subscription_bonus login_bonus email_confirmed registration_bonus)
  scope :enabled, -> { where(enabled: true) }
  scope :within, -> { where('end_at >= ?', Time.current) }
  scope :user_profile_name_cont, ->(name) { joins(user: :user_profile).where("user_profiles.name LIKE '%#{name}%'") }

  def self.ransackable_scopes(_auth_object = nil)
    %i(user_profile_name_cont)
  end

  private

  def added_process_type?
    process_type == 'added'
  end
end
