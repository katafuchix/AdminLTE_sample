module Logic
  module Admin
    module User
      def higher_admin?
        admin? || special?
      end
    end
  end
end
