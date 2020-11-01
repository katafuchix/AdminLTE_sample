class UserMatchMessage < ApplicationRecord
    enum message_type: %w(text photo location)
    belongs_to :user_match, class_name: 'UserMatch'
    belongs_to :sender_user, class_name: 'User'
    belongs_to :receiver_user, class_name: 'User'
    counter_culture :user_match, column_name: 'messages_count'
    #mount_base64_uploader :image, MessageImageUploader
    validate :validate_message_or_image
    validates :image, presence: false, image: { min_width: 200, min_height: 200, max_filesize_mb: 10 }
    validate :valid_user_ids?, if: :user_match
    include Logic::UserMatchMessage
    before_validation :assign_receiver_user, if: :user_match
    scope :latest, -> { order(created_at: :desc, id: :desc) }
    scope :filter_timestamp, lambda { |timestamp|
      where('user_match_messages.created_at > ?', Time.at(timestamp)) if timestamp.present?
    }
    after_create :update_message_unread

    # メッセージが届いたらPush通知送信 and メール送信
    #after_commit do
    #  UserMatchMessageMailer.create(self).deliver_later if receiver_user.sendable_match_message_mail?
    #  receiver_user.send_push_notification('user_match_message_mailer.create.push.body', true) if receiver_user.user_notify.match_message_push_notify
    #end

    # メッセージを作るときは、受信者をセットする
    def assign_receiver_user
      self.receiver_user_id = user_match.receiver_user_id(sender_user_id)
    end

    def valid_user_ids?
      return if user_match.room_id.split(/\D/).map(&:to_i) == [sender_user_id, receiver_user_id].sort
      errors[:base] << I18n.t('user_match_message.message.invalid_user_ids')
    end

    private

    def validate_message_or_image
      unless message.present? || image.present?
        errors[:base] << I18n.t('api.errors.lack_params')
      end
    end
end
