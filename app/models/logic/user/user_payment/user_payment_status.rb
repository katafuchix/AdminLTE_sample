# 会員の購入ステータス判定
module Logic
  module User
    module UserPayment
      module UserPaymentStatus
        extend ActiveSupport::Concern

        # ユーザーが無料会員か判定
        # @return [Boolean] 無料会員か
        def no_charging_member?
          normal_charging_payment.blank? && premium_charging_payment.blank?
        end

        # ユーザーが有料会員か判定
        # @return [Boolean] 有料会員か
        def normal_charging_member?
          normal_charging_payment.present?
        end

        # ユーザーがプレミアム会員か判定
        # @return [Boolean] プレミアム会員か
        def premium_charging_member?
          premium_charging_payment.present?
        end

        # ユーザーが男性かつ有料会員でないか判定
        # @return [Boolean] 無料会員か
        def not_normal_payment_male_member?
          sex == 'male' && !normal_charging_member?
        end

        # 有料会員期限日時
        # @return [Datetime] 期限日時
        def normal_charging_member_expire_date
          max = user_payments.normal_charging.max_by(&:end_at)
          max.try(:end_at)
        end

        # プレミアム会員期限日時
        # @return [Datetime] 期限日時
        def premium_charging_member_expire_date
          max = user_payments.premium_charging.max_by(&:end_at)
          max.try(:end_at)
        end

        # ユーザーの会員状態(payment_type)の名称取得
        # @return [String] Payment_type名
        def payment_type_name
          if premium_charging_member?
            'premium_charging'
          elsif normal_charging_member?
            'normal_charging'
          else
            'no_charging'
          end
        end
      end
    end
  end
end
