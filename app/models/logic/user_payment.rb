module Logic
  module UserPayment
    extend ActiveSupport::Concern

    module ClassMethods
      # 会員期限が切れる一日以内のレコードを取得
      def term_soon(now, is_count = false, limit = nil, offset = nil)
        select_param = is_count ? 'COUNT(*) as count' : 'main.*'
        limit_param = limit ? "LIMIT #{offset}, #{limit}" : ''
        sql = <<-"SQL"
          SELECT #{select_param} FROM user_payments AS main
          LEFT OUTER JOIN user_payments AS sub
          ON main.user_id = sub.user_id
          AND main.payment_type = sub.payment_type
          AND main.end_at < sub.end_at
          AND sub.enabled = 1
          WHERE sub.end_at IS NULL AND main.enabled = 1
          AND main.end_at >= '#{now - 1.day}' AND main.end_at <= '#{now + 1.day}'
          #{limit_param}
        SQL
        find_by_sql(sql)
      end

      # 1時間以内に有料会員の月ごと付与ポイントが発生するユーザのレコードを取得する
      def get_users_to_give_paters_point_in_an_hour(now)
        # batchが処理する期間は、引数で受け取った期間の直前の00分以上、直後の00分未満の間
        start_time = now.strftime('%Y/%m/%d %H:00:00').to_time
        next_term_start_at_range = start_time...(start_time + 1.hour)

        ::UserPayment.enabled.normal_charging.next_term_start_at_in(next_term_start_at_range)
      end
    end
  end
end
