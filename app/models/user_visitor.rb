class UserVisitor < ApplicationRecord
  include Validations::TargetValidation
  include UsersBelongsTo
  belongs_to_user(conditions: -> { where('DATE(created_at) = ?', Date.today) }, scope: :user_id)
  before_create do
    self.read = false
  end

  before_save do
    if self.class._create_callbacks.select { |callback| callback.kind.eql? :after }.collect(&:filter).include?(:_update_counts_after_create)
      self.class.skip_callback(:create, :after, :_update_counts_after_create)
    end
  end

  after_commit do
    self.class.set_callback(:create, :after, :_update_counts_after_create)
  end

  scope :searched_at, lambda { |searched_at = nil|
    where(UserVisitor.arel_table[:updated_at].lteq(searched_at || Time.current))
  }
end
