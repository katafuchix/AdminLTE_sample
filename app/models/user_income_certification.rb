class UserIncomeCertification < ApplicationRecord
  include Approvable
  approvable :document_image
  belongs_to :user
  with_options on: :update do |user_income_certification|
    user_income_certification.validates :document_image, presence: true,
                                                         image: { min_width: 200, min_height: 200, max_filesize_mb: 10 }
  end
#  validates :document_image_rejected_reason, presence: true, if: "self.document_image_status == 'rejected'"
  validates :document_image_rejected_reason, presence: true, if: proc { |s| s.document_image_status_rejected? }
  mount_base64_uploader :document_image, IncomeCertificationUploader
  mount_base64_uploader :document_image_was_accepted, IncomeCertificationUploader
  mount_base64_uploader :document_image_was_rejected, IncomeCertificationUploader
  mount_base64_uploader :document_image_before, IncomeCertificationUploader
  [:remove_document_image!, :remove_document_image_was_accepted!, :remove_document_image_was_rejected!, :remove_document_image_before!].each do |callback|
    skip_callback :commit, :after, callback
  end
  default_value_for :document_image_status, :blanked
end
