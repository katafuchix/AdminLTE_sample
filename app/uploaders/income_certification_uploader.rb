class IncomeCertificationUploader < BaseUploader
  def initialize(*)
    super
    self.fog_public = false
    self.fog_authenticated_url_expiration = 10
  end
end
