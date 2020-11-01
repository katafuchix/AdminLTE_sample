class BaseUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick
  include Piet::CarrierWaveExtension

  storage :fog

  process :set_property
  process resize_to_limit: [1200, 1200]
  #process optimize: [quality: 60] #unless Rails.env.test? || Rails.env.development?

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def filename
    if original_filename.present?
      name = original_filename.split('-')[-1]
      "#{digest}-#{name}"
    end
  end

  def digest
    var = :"@#{mounted_as}_digest"
    #model.instance_variable_get(var) || model.instance_variable_set(var, ::Digest::MD5.file(current_path).hexdigest)
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.uuid)
  end

  def extension_white_list
    %w(jpg jpeg png)
  end

  version :thumb do
    process resize_to_fit: [100, 100]
  end

#  def filename
#      "#{secure_token}.#{file.extension}" if original_filename.present?
#  end

#  protected
#    def secure_token
#        var = :"@#{mounted_as}_secure_token"
#    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.uuid)
#    end
end
