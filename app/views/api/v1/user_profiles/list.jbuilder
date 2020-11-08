
json.result true
json.message I18n.t('api.success_message.get')
json.profiles @users do |user|
  json.partial! partial: 'v1/common/user_profile', locals: {user_profile: user.user_profile}
end
json.loaded_page_index @page.to_i
json.total_count @users.total_count