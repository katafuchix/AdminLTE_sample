module UsersBelongsTo
  extend ActiveSupport::Concern

  class_methods do
    # Userが自己結合するための定義をする
    # @return [Boolean] 成功したかどうか
    def belongs_to_user(uniqueness_options = { scope: :user_id })
      short_name = name.pluralize.underscore.gsub('user_', '')
      belongs_to :user, class_name: 'User'
      belongs_to :target_user, class_name: 'User'
      validates_uniqueness_of :target_user_id, uniqueness_options
      p short_name
      p name
      #unless class_name == 'UserRelation'
      unless name == 'UserRelation'
        counter_culture :user, column_name: "outcomming_#{short_name}_count"
        counter_culture :target_user, column_name: "incomming_#{short_name}_count"
      end
    end
  end
  included do
    scope :without_soft_destroyed, -> { joins(:user).merge(::User.without_soft_destroyed) }
    [:day, :week, :month, :year].each do |range|
      scope range, lambda { |now = Time.current|
        time_range = now.public_send("beginning_of_#{range}")..now.public_send("end_of_#{range}")
        where(created_at: time_range)
      }
    end
  end
end
