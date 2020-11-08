module MediaSite
  module Util
    extend ActiveSupport::Concern

    included do
      helpers do
        # APIトランザクションラッパー 例外発生時にJSONを返す
        # @yield [] トランザクション
        def api_transaction(erorr_object = nil)
          yield if block_given?
        rescue ActiveRecord::RecordNotFound
          error!({ message: I18n.t('api.errors.error_404'), error_code: Settings.api_error_code.invalid }, 400)
        rescue => e
          error_code = Settings.api_error_code.db_transaction
          error_code = e.error_code if defined? e.error_code
          res = { message: e, error_code: error_code }
          res[:where] = error_description_hash(erorr_object) if erorr_object
          error!(res, 400)
        end

        # APIトランザクションラッパー 例外発生時にJSONを返す
        # @yield [] トランザクション
        def create_user_api_transaction(erorr_object, step)
          yield if block_given?
        rescue => e
          error_code = Settings.api_error_code.db_transaction
          error_code = e.error_code if defined? e.error_code
          res = { message: e, error_code: error_code, step: step }
          res[:where] = error_description_hash(erorr_object)
          error!(res, 400)
        end

        # DBトランザクションラッパー トランザクションエラー時にJSONを返す
        # @yield [] トランザクション
        def db_transaction
          api_transaction do
            ActiveRecord::Base.transaction do
              yield if block_given?
            end
          end
        end

        # 引数がnilが判定し、nilの場合400エラーのJSONを返す
        # @param [Object] obj 判定対象のオブジェクト
        def check_empty!(obj)
          return unless obj.blank?
          error!({ message: I18n.t('api.errors.error_404'), error_code: Settings.api_error_code.invalid }, 400)
        end

        # 性別が設定されていない場合バリデーションエラーのJSONを返す
        # @param [Model] target_user userがマッピングされたモデル
        def check_set_sex!
          return unless current_user.user_profile.sex.blank?
          error!({ message: I18n.t('api.errors.sex_is_nil'), error_code: Settings.api_error_code.invalid }, 400)
        end

        # ログインユーザーと比較して異性か判定し、同性の場合バリデーションエラーのJSONを返す
        # @param [Model] target_user userがマッピングされたモデル
        def check_other_sex!(target_user)
          return if current_user.other_sex?(target_user)
          error!({ message: I18n.t('api.errors.same_sex'), error_code: Settings.api_error_code.invalid }, 400)
        end

        # バリデーションとバージョンチェック(iOS)
        # @param [String] target_version 判定元バージョン
        def validate_with_version_check(target_version)
          @force_version_up = force_version_up(target_version)
          @message = current_user.deactivate_message
          @deactivated = @message.present?
        end

        # バリデーションとバージョンチェック(Android)
        # @param [String] target_version 判定元バージョン
        def validate_with_version_check_android(_target_version)
          # TODO: Androidは現状バージョンチェックを行わない
          @force_version_up = false
          @message = current_user.deactivate_message
          @deactivated = @message.present?
        end

        # 強制アップデートするか判定する
        # @param [String] target_version 判定元バージョン
        # @return [Boolean] 判定結果
        def force_version_up(target_version)
          Gem::Version.create(::Version.version) > Gem::Version.create(target_version)
        end

        def check_age_certified?
          status = current_user.user_age_certification.document_image_status
          if current_user.sex == 'male' && %w(accepted pending).include?(status)
            return
          elsif current_user.sex == 'female' && status == 'accepted'
            return
          else
            error!({ message: I18n.t('api.errors.no_age_certified'), error_code: Settings.api_error_code.invalid }, 400)
          end
        end

        def can_receive_messages!
          if current_user.sex == 'male'
            return if current_user.normal_charging_member?
            error!({ message: I18n.t('api.errors.no_normal_charging_member'),
                     error_code: Settings.api_error_code.invalid }, 400)
          end
        end

        # メッセージを送信する相手が退会済みかチェック
        # param [String] room_id ルームID
        def check_whether_target_user_is_deleted!(room_id)
          match = UserMatch.where(room_id: room_id).first
          return unless match.user.soft_destroyed? || match.target_user.soft_destroyed?
          error!({ message: I18n.t('api.errors.target_already_unsubscribed'), error_code: Settings.api_error_code.invalid }, 400)
        end

        # エラーがある時にその詳細をHashにする
        # @params [ActiveModel] エラーオブジェクト(ActiveModel::Validationsをインクルードしていること)
        # @return [Hash] エラー詳細
        def error_description_hash(erorr_object)
          erorr_object.errors.messages.each_with_object({}) do |(k, v), h|
            h[k] = {
              name: erorr_object.class.human_attribute_name(k),
              reason: v
            }
          end
        end
      end
    end
  end
end
