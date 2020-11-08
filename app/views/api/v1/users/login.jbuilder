json.result true
json.message I18n.t('api.success_message.user.login')
json.partial! partial: 'v1/common/user', locals: { user: @user }
