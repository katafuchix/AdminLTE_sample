module Logic
  module User
    module Create
      extend ActiveSupport::Concern

      module ClassMethods
        # APIのリクエストによりユーザーを作成する
        # @param [Hash] params APIリクエストパラメータ
        # @raise バリデーションエラー
        def create_by_request!(params)
          ActiveRecord::Base.transaction do
            user = ::User.new(create_user_params(params))
            user.save!
            user.build_user_profile(create_user_profile_params(params)).save!
            #user.build_user_profile().save!
            #user.send_sms(params[:unconfirmed_mobile_phone])
            user
          end
        end

        private

        def create_user_params(params)
          params.slice(:email, :password, :authentication_token)
        end

        def create_user_profile_params(params)
          params.slice(:prof_address_id, :sex)
        end

        #def create_user_profile_params(params)
        #  params.slice(:name, :sex, :birthday, :prof_address_id, :comment)
        #end
      end
    end
  end
end
