json.result true
json.message I18n.t('api.success_message.get')
json.partial! partial: 'v1/common/profile_image', locals: {user_profile: @profile_image.user_profile, profile_image: @profile_image}
if @profile_image
  json.image @profile_image.image_url
  json.approvable_status @profile_image.image_status
  json.image_approval_values @profile_image.image_approval_values(browse_user: current_user)
end
