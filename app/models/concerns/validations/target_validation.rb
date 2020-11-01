module Validations
  module TargetValidation
    extend ActiveSupport::Concern
    include BaseValidation

    included do
      validate :not_me?
      validate :other_sex?

      private

      # 対象が自分でないことをバリデーション
      # user_idとtarget_user_idを比較
      # @return [String] エラーメッセージ
      def not_me?
        return if errors?
        return unless user_id == target_user_id
        errors[:base] << I18n.t('api.errors.invalid')
      end

      # 対象が異性であることをバリデーション
      # user_idとtarget_user_idの性別を比較
      # @return [String] エラーメッセージ
      def other_sex?
        return if errors?
        users_sex = UserProfile.where(user_id: [user_id, target_user]).pluck(:sex)
        return if users_sex.compact.uniq.count == 2
        errors[:base] << I18n.t('api.errors.same_sex')
      end
    end
  end
end
