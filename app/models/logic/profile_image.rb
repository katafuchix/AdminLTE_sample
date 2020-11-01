module Logic
  module ProfileImage
    extend ActiveSupport::Concern

    # プロフィール画像のapproval_values
    # ステータスに応じてHashを返す 1枚目は公開範囲によって変更
    # @return [Hash] {:#{target} => {value, was_accepted, was_rejected, status}, #{target}_my_page, #{target}_opp_profile }
    def image_approval_values(**arg)
      approvable_columns.each_with_object({}) do |target, h|
        h[target] = approval_value(target)
        my_page_url = (status(target) == 'pending' ? value(target) : was_accepted(target)).to_s
        my_page_url = user_profile.default_icon_url if my_page_url.blank?
        h["#{target}_my_page"] = my_page_url
        h["#{target}_opp_profile"] = opp_profile(target, arg)
      end
    end

    private

    def opp_profile(target, **arg)
      if user_profile.user.deleted_at.present?
        user_profile.default_icon_url
      elsif sort_order && user_profile.check_main_image?(self)
        user_profile.main_image_url(arg)
      else
        user_profile.sub_image_url(self, target, arg)
      end
    end
  end
end
