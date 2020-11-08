json.result true
json.message I18n.t('api.success_message.get')
json.partial! partial: 'v1/common/user_profile', locals: {user_profile: @user.user_profile}
json.profile_images @user.user_profile.profile_images do |profile_image|
  json.partial! partial: 'v1/common/profile_image', locals: {user_profile: @user.user_profile, profile_image: profile_image}
end
if @user.user_profile.user_template
  json.template do
    json.id @user.user_profile.user_template.id
    json.background_image @user.user_profile.user_template.background_image.url
  end
else
  json.template nil
end
