module UserFormValidation
  module Methods

    # Emailのユニークチェック
    def email_uniqueness?
      return unless email.present?
      #return if auth_token_user.try(:email) == email
      user = ::User.find_by(email: email)
      return unless user #&& !user.pass_recreate_ban_term?
      errors.add(:email, I18n.t('errors.messages.taken'))
    end

  end
end
