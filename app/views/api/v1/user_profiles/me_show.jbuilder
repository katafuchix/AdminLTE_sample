json.result true
json.message I18n.t('api.success_message.get')
json.profile do

  json.user_id @user.id
  json.user_profile_id @user.user_profile.id
end

json.profile_images @user.user_profile.profile_images do |profile_image|
  json.partial! partial: 'v1/common/profile_image', locals: {user_profile: @user.user_profile, profile_image: profile_image}
end
