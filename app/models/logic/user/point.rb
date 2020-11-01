module Logic
  module User
    module Point
      extend ActiveSupport::Concern
      # ポイントを交換する
      # @params [Integer] 交換するポイント
      # @return [Boolean] 成功した時のみtrue, それ以外raise
      # @raise バリデーションエラー
      def point_exchange!(point)
        transaction do
          use_point!(point)
          add_relation_point!(point)
        end
      end

      # 残いいねを追加する
      # @params [Integer] 追加する残いいね数
      # @return [User] ユーザ
      def add_remain_relation_count!(count = Settings.relation_point.monthly)
        transaction do
          reload
          increment!(:remain_relation_count, count)
        end
      end

      private

      def add_relation_point!(point)
        reload # reloadを入れない無い場合更新されないので注意
        increment!(:relation_point, point)
      end
    end
  end
end
