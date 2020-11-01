module Logic
  module Notification
    extend ActiveSupport::Concern
    included do
      enum notice_type: %w( normal emergency )
    end

    # 既読か判定
    # @return [Boolean] 既読か
    def read?(user_id)
      !user_notification_reads.where(user_id: user_id).empty?
    end
  end
end
