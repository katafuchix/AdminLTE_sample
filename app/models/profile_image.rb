class ProfileImage < ApplicationRecord
  enum image_role: %w(show_public relation_user_only matching_user_only show_private)
  include Approvable
  approvable :image
  include Logic::ProfileImage
  belongs_to :user_profile
  mount_base64_uploader :image, ProfileImageUploader
  mount_base64_uploader :image_was_accepted, ProfileImageUploader
  mount_base64_uploader :image_was_rejected, ProfileImageUploader
  mount_base64_uploader :image_before, ProfileImageUploader
  [:remove_image!, :remove_image_was_accepted!, :remove_image_was_rejected!, :remove_image_before!].each do |callback|
    skip_callback :commit, :after, callback
  end
  delegate :user, to: :user_profile
  with_options on: [:create, :update] do |profile_image|
    profile_image.validates :image, presence: true, image: { min_width: 200, min_height: 200, max_filesize_mb: 100 }
  end
  #validates :image_rejected_reason, presence: true, if: "self.image_status == 'rejected'"
  validates :image_role, inclusion: %w(show_public relation_user_only matching_user_only show_private), presence: true

  #after_commit do
  #  if user_profile.present? && user_profile.user.present?
  #    user_profile.user.update_column(:profile_images_count, ProfileImage.where(image_status: 'accepted').or(ProfileImage.where.not(image_was_accepted: nil)).where(user_profile_id: user_profile.id).count)
  #  end
  #end

  scope :have_images, -> { where('image_status = 1 AND image_was_accepted IS NOT NULL').group('user_profile_id').select(:user_profile_id) }
  scope :have_sub_images, -> { where('image_status = 1 AND image_was_accepted IS NOT NULL').group(:user_profile_id).having('count(user_profile_id) > 1').pluck(:user_profile_id) }
end
