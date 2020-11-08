json.result true
json.message I18n.t('api.success_message.get')
json.tasks @tasks do |task|
   json.(task, :id, :name, :description)
end
