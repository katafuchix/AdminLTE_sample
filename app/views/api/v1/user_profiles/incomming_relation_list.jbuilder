
json.result true
json.message I18n.t('api.success_message.get')
json.profiles @users do |user|
  json.partial! partial: 'v1/common/user_profile', locals: {user_profile: user.user_profile}
  json.relation_message @relation_messages.detect{|r| r.user_id == user.id}.try(:accepted_message)
end
json.loaded_page_index @page.to_i
json.total_count @users.total_count
