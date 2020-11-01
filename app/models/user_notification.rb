class UserNotification < ApplicationRecord
  has_many :user_notification_reads, as: :notificatable
  belongs_to :user
  attr_accessor :send_mail_and_push_notification

  include Logic::Notification

  validates :notice_type, presence: true
  validates :title, presence: true
  validates :body, presence: true

  after_create :mail_and_push_notification

  private

  def alert
    alert_title = notice_type == 'emergency' ? '【重要なお知らせ】' : '' + title
    {
      title: alert_title,
      body: body
    }
  end

  # send_mail_and_push_notificationがある時のみメールとpush通知を送る
  # send_mail_and_push_notificationはカラムが定義されているわけではないので、
  # このメソッドを使用するときはパラメータに追加してUserNotificationを作成する必要がある
  def mail_and_push_notification
    return unless send_mail_and_push_notification
    user.send_push_notification_with_alert(alert, I18n.t('user_notification_mailer.create.push_link')) if user.user_notify.notification_push_notify
    UserNotificationMailer.create(self).deliver_later if user.email.present? && user.sendable_notification_mail?
  end
end
