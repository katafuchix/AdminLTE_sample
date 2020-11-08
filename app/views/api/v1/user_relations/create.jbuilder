json.result true
if @user_relation.present?
  if @user_relation.user_match
    json.message I18n.t('api.success_message.user_match.create')
    json.room_id @user_relation.user_match.room_id
  else
    json.message I18n.t('api.success_message.user_relation.create')
  end
  json.target_user_id @user_relation.target_user_id
  json.created_at @user_relation.created_at.to_s
end