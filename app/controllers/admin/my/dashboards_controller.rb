module Admin
  module My
    class DashboardsController < Admin::ApplicationController
      before_action :authenticate_admin_user!

      def show
      end
    end
  end
end
