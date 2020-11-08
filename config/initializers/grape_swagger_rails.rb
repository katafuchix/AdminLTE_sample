unless Rails.env.production?
  GrapeSwaggerRails.options.app_name = 'Grape API Sample'
  GrapeSwaggerRails.options.app_url  = '/'
  GrapeSwaggerRails.options.url = 'api/v1/swagger_doc.json'
end
