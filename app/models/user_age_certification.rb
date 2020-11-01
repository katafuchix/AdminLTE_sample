class UserAgeCertification < ApplicationRecord
  attr_reader :document_image_base64
  include Approvable
  approvable :document_image
  belongs_to :user
  with_options on: :update do |user_age_certification|
    user_age_certification.validates :document_image, presence: true,
                                                      image: { min_width: 200, min_height: 200, max_filesize_mb: 10 }
  end
  #validates :document_image_rejected_reason, presence: true, if: "self.document_image_status == 'rejected'"
  mount_base64_uploader :document_image, AgeCertificationUploader
  mount_base64_uploader :document_image_was_accepted, AgeCertificationUploader
  mount_base64_uploader :document_image_was_rejected, AgeCertificationUploader
  mount_base64_uploader :document_image_before, AgeCertificationUploader
  [:remove_document_image!, :remove_document_image_was_accepted!, :remove_document_image_was_rejected!, :remove_document_image_before!].each do |callback|
    skip_callback :commit, :after, callback
  end
  default_value_for :document_image_status, :blanked
  scope :user_profile_name_containt, lambda { |name|
    joins(user: :user_profile).where("user_profiles.name LIKE '%#{name}%'")
  }

  def self.ransackable_scopes(_auth_object = nil)
    %i(user_profile_name_containt)
  end
end
