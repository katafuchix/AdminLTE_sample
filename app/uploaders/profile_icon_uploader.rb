class ProfileIconUploader < BaseUploader
  CIRCLE_SIZE = 300
  process resize_to_fill: [CIRCLE_SIZE, CIRCLE_SIZE]
  process circle: CIRCLE_SIZE

  # アイコンを丸くする
  # @params [Integer] リサイズ後の画像サイズ
  # @return [ProfileIconUploader] 加工後の画像
  def circle(size)
    manipulate!(format: :png) do |img|
      circle = Magick::Image.new size, size
      draw_water_circle(circle, size)
      img.matte = true
      img.composite!(mask(circle), Magick::CenterGravity, Magick::CopyOpacityCompositeOp)
    end
  end

  private

  def draw_water_circle(circle, size)
    draw = Magick::Draw.new
    draw.fill 'black'
    draw.circle size / 2, size / 2, size / 2, 1
    draw.draw circle
  end

  def mask(circle)
    mask = circle.blur_image(0, 1).negate
    mask.matte = false
    mask
  end
end
