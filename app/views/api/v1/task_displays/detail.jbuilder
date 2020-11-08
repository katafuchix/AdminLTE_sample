json.result true
json.message I18n.t('api.success_message.get')
json.task do
  json.(@task, :id, :name, :description)
end
