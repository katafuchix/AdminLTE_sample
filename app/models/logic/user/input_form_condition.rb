# プロフィール入力画面のフォームを定義する
# 男女別
module Logic
  module User
    module InputFormCondition
      extend ActiveSupport::Concern

      # 入力画面の入力を許可するパラメータを取得
      # @return [Array] パラメータ一覧
      def user_profile_permit_params
        return [] if edit_type.blank?
        if edit_type == ::UserProfile::EDIT_TYPE['create']
          return user_profile_permit_params_create
        elsif edit_type == ::UserProfile::EDIT_TYPE['update']
          return user_profile_permit_params_update
        end
        []
      end

      # 入力画面の入力を許可するパラメータを取得
      # @abstract
      # @return [Array] パラメータ一覧
      def user_profile_permit_params_create
        fail StandardError, 'Required to override user_profile_permit_params_create!'
      end

      # 入力画面の入力を許可するパラメータを取得
      # @abstract
      # @return [Array] パラメータ一覧
      def user_profile_permit_params_update
        fail StandardError, 'Required to override user_profile_permit_params_update!'
      end

      # プロフィール入力画面の状態を返却
      # @return [Hash] 入力画面状態
      def input_form_condition
        return {} if edit_type.blank?
        if edit_type == ::UserProfile::EDIT_TYPE['create']
          return { input_form_condition: input_form_condition_create }
        elsif edit_type == ::UserProfile::EDIT_TYPE['update']
          return { input_form_condition: input_form_condition_update }
        end
        {}
      end

      # プロフィール入力画面の状態を返却
      # @abstract
      # @return [Hash] 入力画面状態
      def input_form_condition_create
        fail StandardError, 'Required to override input_form_condition_create!'
      end

      # プロフィール入力画面の状態を返却
      # @abstract
      # @return [Hash] 入力画面状態
      def input_form_condition_update
        fail StandardError, 'Required to override input_form_condition_update!'
      end
    end
  end
end
