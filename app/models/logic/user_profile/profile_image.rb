module Logic
  module UserProfile
    module ProfileImage
      extend ActiveSupport::Concern

      included do
        extend Grape::API::Helpers
        include CarrierwaveUtil
        include InstanceMethods
      end

      module InstanceMethods
        # メイン画像をプロフィールアイコンにする
        def update_main_image!
          images = profile_images
          main_image = images.image_accepted.order(sort_order: :asc).first.try(:image)
          main_image ||= images.where.not(image_was_accepted: nil).order(sort_order: :asc).first.try(:image_was_accepted)
          if main_image.try(:url).present?
            update!(icon: main_image)
          elsif icon.present?
            remove_icon!
            save
          end
        end

        # プロフィール画像を登録する
        # @param [Hash] params APIリクエストパラメータ
        # @raise バリデーションエラー
        def create_images_by_request!(params)
          check_image_limit!
          # 末尾に追加
          image = profile_images.create!(image: base64_conversion(params[:image]), sort_order: profile_images.length)
          # add
          image.target_pending_to_accepted!(:image)
          #::Admin::SubmittedNotificationMailer.profile_image(self).deliver_later
          #SlackService.submitted_profile_image(self)
        end

        # プロフィール画像を更新する
        # @param [Hash] params APIリクエストパラメータ
        # @raise バリデーションエラー
        def update_image_by_request!(params)
          img = ::ProfileImage.includes(:user_profile).find_by!(user_profile_id: id, sort_order: params[:target_sort_order])
          img.update!(image: base64_conversion(params[:image]))
          #::Admin::SubmittedNotificationMailer.profile_image(self).deliver_later
          #SlackService.submitted_profile_image(self)
        end

        # プロフィール画像を並び替える
        # @param [Hash] params APIリクエストパラメータ
        # @raise バリデーションエラー
        def update_image_sort_by_request!(params)
          update_image_sort_order!(params[:start_sort_order], params[:end_sort_order])
        end

        # プロフィール画像を削除する
        # @param [Hash] params APIリクエストパラメータ
        # @raise バリデーションエラー
        def delete_image_sort_by_request!(params)
          img = ::ProfileImage.includes(:user_profile)
                              .find_by!(user_profile_id: id, sort_order: params[:target_sort_order])
          img.destroy!
          shift_back_images!(params[:target_sort_order])
        end

        # プロフィール画像の権限を変更する
        # メイン画像の時、プロフィール画像の権限は変更できない
        # @param [Hash] params APIリクエストパラメータ
        # @raise バリデーションエラー
        def update_image_role_by_request!(params)
          img = ::ProfileImage.find_by!(user_profile_id: id, sort_order: params[:target_sort_order])
          fail I18n.t('api.errors.profile_image.update_role') if check_main_image?(img)
          img.update!(image_role: params[:target_role])
        end

        private

        def check_image_limit!
          return if user.user_profile.profile_images.count < Settings.profile_images.limit
          fail I18n.t('api.errors.user_profile.limit', limit: Settings.profile_images.limit)
        end

        def update_image_sort_order!(start_sort_order, end_sort_order)
          start_img = detect_profile_images(start_sort_order)
          end_img = detect_profile_images(end_sort_order)
          if start_img.blank? || end_img.blank?
            # 見つからない場合は例外
            fail ActiveRecord::RecordNotFound
          end
          update_order!(start_img, end_img, start_sort_order, end_sort_order)
        end

        def update_order!(start_img, end_img, start_sort_order, end_sort_order)
          start_img.sort_order = end_sort_order
          end_img.sort_order = start_sort_order
          start_img.image_role = end_img.image_role if check_main_image?(end_img)
          end_img.image_role = start_img.image_role if check_main_image?(start_img)
          start_img.save!
          end_img.save!
        end

        def shift_back_images!(target_sort_order)
          # 後方の画像のsort_orderを更新
          profile_images.includes(:user_profile).each do |image|
            if image.sort_order > target_sort_order.to_i
              image.sort_order -= 1
              image.save!
            end
          end
        end

        def detect_profile_images(sort_order)
          profile_images.joins(:user_profile).includes(:user_profile).detect { |img| img.sort_order == sort_order.to_i }
        end
      end
    end
  end
end
