# frozen_string_literal: true

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable #, :trackable,
  include DeviseTokenAuth::Concerns::User
  include Logic::User

  enum search_status: %w(normal_order low_order)
  has_one :user_profile, class_name: 'UserProfile', dependent: :destroy
  has_one :user_age_certification, dependent: :destroy

  soft_deletable column: :deleted_at

  attr_accessor :edit_type

  scope :males, -> { joins(:user_profile).where(user_profiles: { sex: ::UserProfile.sexes[:male] }) }
  scope :females, -> { joins(:user_profile).where(user_profiles: { sex: ::UserProfile.sexes[:female] }) }
  delegate :sex, to: :user_profile, allow_nil: true

  has_many :articles, class_name: 'Article', dependent: :destroy

  include UsersHasMany
  create_self_association :user_matchs
  create_self_association :user_relations
  create_self_association :user_favorites
  create_self_association :user_blocks
  create_self_association :user_violations
  create_self_association :user_displays
  create_self_association :user_visitors
  create_self_association :user_pickups
  create_self_association :user_memos

  # user_match_idを持っているいいねレコード
  has_many :incomming_matched_relations, -> { where.not(user_match_id: nil) }, class_name: 'UserRelation', foreign_key: :target_user_id, dependent: :destroy
  has_many :incomming_matched_relation_users, through: :incomming_matched_relations, source: :user

  # スキップしたいいねレコード
  has_many :outcomming_relation_skipped, -> { where(skipped: true) }, class_name: 'UserRelation', foreign_key: :target_user_id
  has_many :outcomming_relation_users_skipped, through: :outcomming_relation_skipped, source: :user

  # いいねユーザー
  has_many :outcomming_active_relations, -> { where(active: true) }, class_name: 'UserRelation', dependent: :destroy
  has_many :incomming_active_relations, -> { where(active: true) }, class_name: 'UserRelation', foreign_key: :target_user_id, dependent: :destroy
  has_many :outcomming_active_relation_users, through: :outcomming_active_relations, source: :target_user
  has_many :incomming_active_relation_users, through: :incomming_active_relations, source: :user
  has_many :outcomming_pending_relations, -> { where(active: false) }, class_name: 'UserRelation', dependent: :destroy
  has_many :incomming_pending_relations, -> { where(active: false) }, class_name: 'UserRelation', foreign_key: :target_user_id, dependent: :destroy
  has_many :outcomming_pending_relation_users, through: :outcomming_pending_relations, source: :target_user
  has_many :incomming_pending_relation_users, through: :incomming_pending_relations, source: :user

  after_create :create_user_age_certification, unless: proc { |user| user.user_age_certification }


  has_one :user_income_certification, dependent: :destroy
  has_one :user_billing, dependent: :destroy
  has_one :user_notify, dependent: :destroy
  has_one :user_app_version_info, dependent: :destroy
  has_one :user_rank, dependent: :destroy
  has_one :admin_user_probation, class_name: 'Admin::UserProbation', dependent: :destroy
  has_one :inspector_user, dependent: :destroy
  has_one :inspector_white_list, dependent: :destroy
  has_many :user_purchase_histories, dependent: :destroy
  has_many :user_purchase_subscriptions, dependent: :destroy
  has_many :user_ios_purchase_histories, dependent: :destroy
  has_many :user_android_purchase_histories, dependent: :destroy
  has_many :user_payments, -> { enabled.order('updated_at DESC') }, dependent: :destroy
  has_many :user_notifications, dependent: :destroy
  has_many :user_notification_reads, dependent: :destroy
  has_many :user_point_payments, dependent: :destroy
  has_many :user_point_payments_histories, -> { order('created_at DESC') }, dependent: :destroy,
                                                                            class_name: 'UserPointPayment'
  has_many :user_have_point_payments, -> { enabled.within.added.order('created_at ASC') },
           class_name: 'UserPointPayment'
  has_many :user_invite_codes


  after_create :create_user_notify, unless: proc { |user| user.user_notify }




  scope :sum_remain_point_with_user, -> (uid) { where(id: uid).joins(:user_have_point_payments).group('users.id').sum(:remain_point) }

end
