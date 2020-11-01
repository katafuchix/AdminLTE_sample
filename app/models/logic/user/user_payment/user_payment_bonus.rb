# ボーナス付与と、実行、通知
module Logic
  module User
    module UserPayment
      module UserPaymentBonus
        extend ActiveSupport::Concern
        PAYMENT_EXPERIENCE_TYPE_NAME = {
          become_paying:    '有料会員へのご登録',
          continue_paying:  '有料会員のご更新'
        }.freeze
        PAYMENT_PREMIUM_EXPERIENCE_TYPE_NAME = {
          become_paying:    'プレミアム会員へのご登録',
          continue_paying:  'プレミアム会員のご更新'
        }.freeze

        def payment_bonus(product_id, point_type = 'subscription_bonus')
          purchase_payingmember = ::PurchasePayingmember.find_by(product_id_str: product_id)
          return if purchase_payingmember.blank?
          campaigns = purchase_payingmember.opening_purchase_payingmember_campaigns
                                           .where.not(sex: sex == 'male' ? 'female' : 'male')
                                           .where.not(contact_type: purchase_restoring? ? 'new_only' : 'continue_only')
                                           .includes(:purchase_payingmember)
          campaigns.each do |campaign|
            # ボーナスを付与し，お知らせ通知する
            case campaign.campaign_type
            when 'pater_point'
              add_point!(campaign.value, point_type)
            when 'relation_point'
              add_remain_relation_count!(campaign.value)
            end
            user_notifications.create!(bonus_notification_params(campaign))
          end
        end

        private

        def bonus_notification_params(campaign)
          if campaign.name == 'サマーキャンペーン'
            bonus_summer_notification_params(campaign)
          else
            bonus_point_notification_params(campaign)
          end
        end

        def bonus_point_notification_params(campaign)
          {
            title: I18n.t('notification.bonus.title', campaign_type: campaign.campaign_type_i18n),
            body: format(I18n.t('notification.bonus.body'),
                         payment_type: bonus_notification_payment_type(campaign),
                         point: campaign.value,
                         campaign_type: campaign.campaign_type_i18n),
            notice_type: :normal
          }
        end

        def bonus_summer_notification_params(campaign)
          {
            title: I18n.t('notification.summer_bonus.title', campaign_type: campaign.campaign_type_i18n),
            body: format(I18n.t('notification.summer_bonus.body'),
                         payment_type: bonus_notification_payment_type(campaign),
                         point: campaign.value,
                         campaign_type: campaign.campaign_type_i18n),
            notice_type: :normal
          }
        end

        def bonus_notification_payment_type(campaign)
          if campaign.purchase_payingmember.is_premium
            PAYMENT_PREMIUM_EXPERIENCE_TYPE_NAME[purchase_restoring? ? :continue_paying : :become_paying]
          else
            PAYMENT_EXPERIENCE_TYPE_NAME[purchase_restoring? ? :continue_paying : :become_paying]
          end
        end
      end
    end
  end
end
