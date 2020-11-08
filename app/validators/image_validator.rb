class ImageValidator < ActiveModel::EachValidator
  OPTIONS = {
    min_width: {
      field:    :width,
      function: :'>=',
      message:  'invalid_image_min_width'
    },
    min_height: {
      field:    :height,
      function: :'>=',
      message:  'invalid_image_min_height'
    },
    max_filesize_mb: {
      field:    :filesize_mb,
      function: :'<=',
      message:  'invalid_image_max_filesize'
    }
  }.freeze

  # 画像サイズを検証する
  # @params [Model] record モデルインスタンス
  # @params [Symbole] attribute カラム名
  # @params [Any] value カラムに渡された検証すべき値
  # @return [String] エラーメッセージ
  def validate_each(record, attribute, value)
    return if value.nil? || value.property.nil?
    property = value.property
    options.each do |key, val|
      next unless OPTIONS.key? key
      check = OPTIONS[key]
      next if validate_for_image(check, val, property, record, attribute)
      record.errors[attribute] << I18n.t("api.errors.#{check[:message]}", limit: val)
    end
  end

  def validate_for_image(check, val, property, record, attribute)
    return true if property[check[:field]].public_send check[:function], val
    return true if record.errors[attribute].present?
  end
end
