class UserPurchaseHistory < ApplicationRecord
  belongs_to :user, optional: true

  # stripe::chargeオブジェクトからuser_purchase_historyを作成するメソッド
  # @params [Class] charge_obj Stripe::Chargeのインスタンス
  # @params [String] product_id_str 強制的にproduct_id_strを指定するもの。なければchargeのmetadataから拾う
  def self.new_by_stripe(charge_object, product_id_str = nil)
    # 退会済みユーザでも取るように
    user_id = User.find_by(customer_id: charge_object[:customer]).try(:id)

    source_object = charge_object[:source] || {}

    product_id_str = charge_object[:metadata].try(:product_id_str) unless product_id_str
    charge_id = charge_object[:id]
    customer_id = charge_object[:customer]
    amount = charge_object[:amount]
    source_id = source_object[:id]
    card_brand = source_object[:brand]
    card_last4 = source_object[:last4]
    charge_at = charge_object[:created] ? Time.at(charge_object[:created]) : nil

    failure_code = charge_object[:failure_code]
    failure_message = charge_object[:failure_message]

    # もしすでに登録済みのレシートだった場合は、以前のものを渡す
    # そうでなければ今回のものを返す
    # TODO: 過去のレコードを渡されたパラメータに変更して返す
    find_by(charge_id: charge_id) || new(
      user_id: user_id,
      product_id_str: product_id_str,
      charge_id: charge_id,
      customer_id: customer_id,
      amount: amount,
      source_id: source_id,
      card_brand: card_brand,
      card_last4: card_last4,
      charge_at: charge_at,
      failure_code: failure_code,
      failure_message: failure_message
    )
  end
end
