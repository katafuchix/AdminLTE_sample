class UserProfile < ApplicationRecord
  include Logic::UserProfile
  include Approvable
  enum sex: %w(male female)
  enum blood: %w(a b o ab)
  approvable :comment, :good_place, :date_place, :dream, :school_name, :hobby, :job_name, :tweet
  acts_as_taggable_on :personality

  belongs_to :user, class_name: 'User'
  belongs_to :prof_annual_income, class_name: 'Master::AnnualIncome', optional: true
  belongs_to :prof_drinking_habit, class_name: 'Master::DrinkingHabit', optional: true
  belongs_to :prof_educational_background, class_name: 'Master::EducationalBackground', optional: true
  belongs_to :prof_expect_support_money, class_name: 'Master::ExpectSupportMoney', optional: true
  belongs_to :prof_figure, class_name: 'Master::Figure', optional: true
  belongs_to :prof_first_date_cost, class_name: 'Master::FirstDateCost', optional: true
  belongs_to :prof_have_child, class_name: 'Master::HaveChild', optional: true
  belongs_to :prof_holiday, class_name: 'Master::Holiday', optional: true
  belongs_to :prof_job, class_name: 'Master::Job', optional: true
  belongs_to :prof_marriage, class_name: 'Master::Marriage', optional: true
  belongs_to :prof_personality, class_name: 'Master::Personality', optional: true
  belongs_to :prof_prefecture, class_name: 'Master::Prefecture', optional: true
  belongs_to :prof_request_until_meet, class_name: 'Master::RequestUntilMeet', optional: true
  belongs_to :prof_smoking_habit, class_name: 'Master::SmokingHabit', optional: true
  belongs_to :prof_address, class_name: 'Master::Prefecture', optional: true
  belongs_to :prof_birth_place, class_name: 'Master::Prefecture', optional: true
  belongs_to :user_template, optional: true

  has_many :profile_images, -> { order(:sort_order) }, dependent: :destroy
  mount_base64_uploader :icon, ProfileIconUploader
  mount_base64_uploader :background_image, ProfileBackgroundImageUploader

  #validates :icon, presence: false, image: { min_width: 200, min_height: 200, max_filesize_mb: 10 }
  #validates :background_image, presence: false, image: { max_filesize_mb: 10 }

  validates :sex, presence: true

end
