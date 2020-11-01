require 'csv'

CSV.generate do |csv|
  csv << [
      'email',
      'mobile_phone',
      'birthday',
      'sex',
      'country',
      'prefecture',
  ]
  @users.each do |user|
    email = if user.deleted_at.present?
              if user.withdrawal_user_email.present?
                user.withdrawal_user_email
              else
                user.email.try(:split, "-OldAccount-").try(:first)
              end
            else
              user.try(:email)
            end
    mobile_phone = if user.deleted_at.present?
                     if user.withdrawal_user_mobile_phone.present?
                       user.formal_phone_number(user.withdrawal_user_mobile_phone, false)
                     elsif user.mobile_phone.present?
                       user.formal_phone_number(user.mobile_phone, false)
                     end
                   else
                     user.formal_phone_number(user.mobile_phone, false) if user.mobile_phone.present?
                   end
    csv << [
        email,
        mobile_phone,
        user.user_profile.birthday.try(:to_date),
        user.user_profile.male? ? 'M' : 'F',
        'JP',
        Settings.prefecture[user.user_profile.prof_address.try(:name)],
    ]
  end
end
