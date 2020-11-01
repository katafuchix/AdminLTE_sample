class UserLoginBonus < ApplicationRecord
  belongs_to :user
  attr_accessor :skip_update_daily_login_date_callback
  before_save { update_daily_login_date unless skip_update_daily_login_date_callback }

  private

  def update_daily_login_date
    self.daily_serial_login_count = 1 if new_record?
    self.daily_login_date = Time.current.beginning_of_day
    self.daily_serial_login_beginning_date = Time.current.beginning_of_day if daily_serial_login_count == 1
  end
end
