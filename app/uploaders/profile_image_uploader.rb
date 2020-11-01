class ProfileImageUploader < BaseUploader
  IMAGE_SIZE = 200
  process resize_to_fill: [IMAGE_SIZE, IMAGE_SIZE]
end
