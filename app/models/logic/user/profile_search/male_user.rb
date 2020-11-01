# 男性限定の検索条件を定義
module Logic
  module User
    module ProfileSearch
      module MaleUser
        extend ActiveSupport::Concern

        # 入力項目の検索条件
        # @return [Array] 検索条件一覧
        def common_conditions
          conditions = super
          conditions << dream_condition
          conditions
        end

        # プレミアム会員のみの検索条件
        # @return [Array] 検索条件一覧
        def premium_conditions
          conditions = super
          conditions << common_type_condition
          conditions << freeword_condition
          conditions
        end

        # ユーザーが検索不能なパラメータ
        # @return [Array] パラメータ一覧
        def reject_ransack_keys
          p = [:user_profile_prof_annual_income_id_in]
          super.concat(p)
        end

        # プレミアムのみ検索可能なパラメータ
        # @return [Array] パラメータ一覧
        def premium_ransack_keys
          p = [:common_type_true, :freeword_cont]
          super.concat(p)
        end

        private

        def dream_condition
          {
            key: "#{user_profile_search_key_prefix}_dream_was_accepted_cont", name: I18n.t('search.name.dream'),
            input_type: INPUT_TYPE[:input], condition_sort_order: 11
          }
        end
      end
    end
  end
end
