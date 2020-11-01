# ユーザのステータス（表示用でつかう）
module Logic
  module User
    module Status
      extend ActiveSupport::Concern

      # 年齢確認済みかどうか
      # @return [Boolean] 年齢確認済みならture, それ以外false
      def age_certified?
        user_age_certification.present? && user_age_certification.document_image_accepted?
      end

      # 年齢確認中または確認済みかどうか
      # @return [Boolean] 判定結果
      def age_pending_or_certified?
        user_age_certification.document_image_pending? ||
          age_certified?
      end

      # 所得証明確認済みかどうか
      # @return [Boolean] 所得証明確認済みならture, それ以外false
      def income_certified?
        user_income_certification && user_income_certification.document_image_accepted?
      end

      # ユーザーがオンラインかどうか
      # @return [Boolean] オンラインかどうか
      # @note Settings.online_minutes.minutesで何分前までオンラインとみなすか指定
      def online?
        current_sign_in_at ? current_sign_in_at > (Time.current - Settings.online_minutes.minutes) : false
      end

      # 対象ユーザーが異性か判定
      # @param [Model] user userがマッピングされたモデル
      # @return [Boolean] 異性:true 同性:false
      def other_sex?(user)
        user_profile.sex != user.user_profile.sex
      end

      # 登録日が新しいか判定
      def just_started?
        created_at >= Time.current - 3.days
      end

      # 人気急上昇中か判定
      # TODO: 仕様が決まったら実装
      def popular?
        true
      end

      # メッセージ好きか判定
      # TODO: 仕様が決まったら実装
      def like_message?
        true
      end

      # 共通点があるか判定
      # TODO: 仕様が決まったら実装
      def common_type?
        true
      end

      # 承認・非承認に関わらず、既に年齢確認が済んでいるかどうかを返す
      def checked_age_confirmation?
        user_age_certification.document_image_was_accepted.url.present? || user_age_certification.document_image_was_rejected.url.present?
      end

      # 違反ユーザーか判定
      # @return [Boolean] 判定結果
      def violated?
        incomming_violations_count >= Settings.account_ban.violation_count
      end

      # 不正ユーザーか判定してエラーメッセージを返却
      # @return [String] エラーメッセージ
      def deactivate_message
        return I18n.t('api.errors.deactivate.violation') if violated?
        nil
      end

      # ユーザー再作成の期限期間を超えているか
      # @return [Boolean] 判定
      def pass_recreate_ban_term?
        deleted_at.present? && Time.current - deleted_at >= Settings.user.recreate_ban_day_term.days
      end
    end
  end
end
