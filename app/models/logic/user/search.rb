module Logic
  module User
    module Search
      extend ActiveSupport::Concern
      # APIのリクエストから異性ユーザーの一覧を取得する
      # @param [Hash] param APIリクエストパラメータ
      # @return [Array] 異性のユーザー一覧
      def other_sex_user_list_by_request(param)
        q = ::User.ransack(adjust_ransack_param(param))
        q.sorts = param[:sorts] if param[:sorts]
        q.result
      end

      # おすすめ異性ユーザーの一覧を取得する
      # @return [Array] 異性のユーザー一覧
      def other_sex_recommend_user_list
        # 人気会員(足あとをもらった数＋いいねをもらった数の合計値を計算して多い順)
        # 居住地が一致 or 近隣都道府県
        near_prefecture = ::SearchUtil.create_near_prefecture
        address_ids = [user_profile.prof_address_id] + (near_prefecture[user_profile.prof_address_id] || [])
        params = { 'user_profile_prof_address_id_in' => address_ids }
        other_sex_user_list_by_request(params).popular_order
                                              .page(1).per(Settings.paging_per.recommend_user.list)
                                              .includes(:user_payments, user_profile: ::UserProfile.eager_loading_list)
      end

      # APIのリクエストからプレミアム会員をピックアップする
      # @param [Hash] param APIリクエストパラメータ
      # @return [Array] ピックアップしたユーザー一覧
      def pickup_premium_user_by_request(param)
        q = ::User.ransack(adjust_ransack_param_premium(param))
        q.sorts = param[:sorts] if param[:sorts]
        users = q.result
        return [] if users.length == 0
        ids = users
              .current_sign_in(param[:searched_at])
              .search_condition(self, nil, []).sample(Settings.user.permium_pickup_max).pluck(:id)
        ::User.where(id: ids)
              .includes(:user_payments, user_profile: ::UserProfile.eager_loading_list).shuffle
      end

      # search_statusを変更する
      # @raise search_statusが追加されたときのためにnormal_order, low_order以外ならエラーが発生する
      def toggle_search_status!
        if normal_order?
          low_order!
        elsif low_order?
          normal_order!
        else
          fail StandardError, "#{I18n.t('activerecord.attributes.user.search_status')}は不正な値です"
        end
      end
    end
  end
end
