# 購入後の、メール送信
module Logic
  module User
    module UserPayment
      module UserPaymentMail
        extend ActiveSupport::Concern
        def send_payingmember_mail(is_premium)
          return unless sendable_notification_mail?
          if is_premium
            PurchaseMailer.become_premium_payingmember(self).deliver_later
          else
            PurchaseMailer.become_payingmember(self).deliver_later
          end
        end
      end
    end
  end
end
