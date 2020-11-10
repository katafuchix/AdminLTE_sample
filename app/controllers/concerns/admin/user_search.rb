module Admin
  module UserSearch
    extend ActiveSupport::Concern
    # 検索で使うインスタンスを初期化
    # @params [Hash] params
    # @return [User] 検索結果のユーザ一覧
    def filtered_users(param)
      @conditions = search_conditions
      @q = ransack_query(param)
      @users = filtered_by_ransack_users(@q)
      @users = filtered_by_search_filter_users(@users, param)
    end

    private

    # 検索条件
    def search_conditions
      ::User.new.profile_search_conditions(true)
    end

    # パラメータからransackのクエリをつくる
    def ransack_query(param)
      ::User.ransack(::User.new.adjust_ransack_param(param.to_unsafe_h, true))
    end

    # ransackで絞り込み
    def filtered_by_ransack_users(q)
      q.result.joins(:user_profile)
    end

    # 独自定義した絞り込み
    def filtered_by_search_filter_users(users, param)
      users = Filter.sex_search(users, param)
      users = Filter.user_ids_search(users, param)
      users = Filter.name_search(users, param)
      users = Filter.email_search(users, param)
      users = Filter.member_type_search(users, param)
      users = Filter.age_verified_search(users, param)
      users = Filter.tel_search(users, param)
      users = Filter.comment_search(users, param)
      users = Filter.tweet_search(users, param)
      users = Filter.dream_search(users, param)
      users = Filter.school_name_search(users, param)
      users = Filter.job_name_search(users, param)
      users = Filter.hobby_search(users, param)
      users
    end

    # 管理画面の会員検索で使う独自メソッドは、こちらに定義します
    module Filter
      module_function

      def sex_search(users, param)
        return users unless param[:sex].present?
        param[:sex] == 'male' ? users.males : users.females
      end

      def user_ids_search(users, param)
        return users unless param[:user_id].present?
        users.where(id: param[:user_id].split(/\D/))
      end

      def name_search(users, param)
        return users unless param[:name].present?
        users.where('user_profiles.name like ?', %(%#{param[:name]}%))
      end

      def email_search(users, param)
        return users unless param[:email].present?
        users.where('users.email like ?', %(%#{param[:email]}%))
      end

      def tel_search(users, param)
        return users unless param[:mobile_phone].present?
        users.where('users.mobile_phone like ? OR users.unconfirmed_mobile_phone like ?', %(%#{param[:mobile_phone]}%), %(%#{param[:mobile_phone]}%))
      end

      def comment_search(users, param)
        return users unless param[:comment].present?
        users.where('user_profiles.comment like ? OR user_profiles.comment_was_accepted like ?', %(%#{param[:comment]}%), %(%#{param[:comment]}%))
      end

      def tweet_search(users, param)
        return users unless param[:tweet].present?
        users.where('user_profiles.tweet like ? OR user_profiles.tweet_was_accepted like ?', %(%#{param[:tweet]}%), %(%#{param[:tweet]}%))
      end

      def dream_search(users, param)
        return users unless param[:dream].present?
        users.where('user_profiles.dream like ? OR user_profiles.dream_was_accepted like ?', %(%#{param[:dream]}%), %(%#{param[:dream]}%))
      end

      def school_name_search(users, param)
        return users unless param[:school_name].present?
        users.where('user_profiles.school_name like ? OR user_profiles.school_name_was_accepted like ?', %(%#{param[:school_name]}%), %(%#{param[:school_name]}%))
      end

      def job_name_search(users, param)
        return users unless param[:job_name].present?
        users.where('user_profiles.job_name like ? OR user_profiles.job_name_was_accepted like ?', %(%#{param[:job_name]}%), %(%#{param[:job_name]}%))
      end

      def hobby_search(users, param)
        return users unless param[:hobby].present?
        users.where('user_profiles.hobby like ? OR user_profiles.hobby_was_accepted like ?', %(%#{param[:hobby]}%), %(%#{param[:hobby]}%))
      end

      def member_type_search(users, param)
        return users unless param[:member_type].present?
        payments = UserPayment.where('enabled = 1 AND start_at <= :current AND :current <= end_at', current: Time.current.to_s)
        user_ids = payments.where('payment_type IN (0, 1)').map(&:user_id) if param[:member_type] == '1'
        user_ids = payments.where('payment_type = 0').map(&:user_id) if param[:member_type] == '2'
        user_ids = payments.where('payment_type = 1').map(&:user_id) if param[:member_type] == '3'
        param[:member_type] == '1' ? users.where.not(id: user_ids) : users.where(id: user_ids)
      end

      def age_verified_search(users, param)
        return users unless param[:age_confirm].present?
        user_ids = UserAgeCertification.document_image_accepted.map(&:user_id)
        param[:age_confirm] == '2' ? users.where(id: user_ids) : users.where.not(id: user_ids)
      end
    end
  end
end
