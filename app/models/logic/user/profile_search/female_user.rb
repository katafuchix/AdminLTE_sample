# 女性限定の検索条件を定義
module Logic
  module User
    module ProfileSearch
      module FemaleUser
        extend ActiveSupport::Concern

        # 入力項目の検索条件
        # @return [Array] 検索条件一覧
        def common_conditions
          conditions = super
          conditions << annual_condition
          conditions << common_type_condition
          conditions << freeword_condition
          conditions
        end

        # ユーザーが検索不能なパラメータ
        # @return [Array] パラメータ一覧
        def reject_ransack_keys
          p = [:user_profile_dream_cont]
          super.concat(p)
        end

        private

        def annual_condition
          {
            key: "#{user_profile_search_key_prefix}_prof_annual_income_id_in",
            name: I18n.t('activerecord.models.master/annual_income'),
            contents: Master::AnnualIncome.contents, condition_sort_order: 17,
            input_type: INPUT_TYPE[:multiple]
          }
        end
      end
    end
  end
end
