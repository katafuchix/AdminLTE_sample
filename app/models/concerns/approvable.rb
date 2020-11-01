# カラムに承認フローを追加します
#
# @note #{target} = 承認フローを追加するカラム名
#
# 必須カラム: #{target}_status [Integer] 承認ステータス
#             #{target}_confirmed_at [Datetime] 承認日時
#             #{target}_was_accepted [Any] #{target}カラムが承認された場合のコピー場所
#             #{target}_was_rejected [Any] #{target}カラムが拒否された場合のコピー場所
#
# 追加されるメソッド
#   #{target}_status 承認ステータス
#     @return [Symbole] 承認ステータス(:pending, :accepted, :rejected, :blanked)
#
# 追加されるコールバック
#    before_save
#      #{target}が更新されるとき、#{target}_confirmed_atをnil & #{target}_statusをpending!
#
# 追加されるスコープ
#   #{target}_pending: 保留中
#   #{target}_accepted: 承認済み
#   #{target}_rejected: 拒否済み
# rubocop:disable Metrics/ModuleLength
module Approvable
  extend ActiveSupport::Concern
  REQUIRED_COLUMN = Set.new(%w(target_status target_confirmed_at target_was_accepted target_was_rejected target_before target_rejected_reason)).freeze
  STATUS = {
    pending: 0,
    accepted: 1,
    rejected: 2,
    blanked: 3
  }.freeze
  included do
    cattr_accessor :approvable_columns
    self.approvable_columns = []

    # 更新された値を承認する
    # @params [Symbol] target_column 対象カラム
    def target_pending_to_accepted!(target_column)
      return unless %w(blanked pending).include?(public_send("#{target_column}_status"))
      public_send("#{target_column}_status=", STATUS[:accepted])
      public_send("#{target_column}_before=", public_send("#{target_column}_was_accepted"))
      public_send("#{target_column}_was_accepted=", public_send(target_column))
      public_send("#{target_column}_confirmed_at=", Time.current)
      save!
    end

    # 承認された値を更新する
    # @params [Hash] target 更新対象のカラム名と値のハッシュ
    def target_accepted_to_pending!(target)
      target_column = target.keys.first
      return unless public_send("#{target_column}_status").eql?('accepted')
      public_send("#{target_column}_status=", STATUS[:pending])
      public_send("#{target_column}=", target[target_column])
      public_send("#{target_column}_confirmed_at=", nil)
    end

    # 更新された値を非承認する
    # @params [Symbol] target_column 対象カラム
    # @params [String] rejected_reason 非承認理由
    def target_pending_to_rejected!(target_column, rejected_reason)
      return unless %w(blanked pending).include?(public_send("#{target_column}_status"))
      public_send("#{target_column}_status=", STATUS[:rejected])
      public_send("#{target_column}_was_rejected=", public_send(target_column))
      public_send("#{target_column}_rejected_reason=", rejected_reason)
      public_send("#{target_column}_confirmed_at=", Time.current)
      save!(validate: false)
    end

    # 非承認された状態で更新する
    # @params [Hash] target 更新対象のカラムと値のハッシュ
    def target_rejected_to_pending!(target)
      target_column = target.keys.first
      return unless public_send("#{target_column}_status").eql?('rejected')
      public_send("#{target_column}_status=", STATUS[:pending])
      public_send("#{target_column}_was_rejected=", target[target_column])
      public_send("#{target_column}=", target[target_column])
      public_send("#{target_column}_confirmed_at=", nil)
    end

    # 承認された値を非承認する
    # @params [Symbol] target_column 対象カラム
    # @params [String] rejected_reason 非承認理由
    def target_accepted_to_rejected!(target_column, rejected_reason)
      return unless public_send("#{target_column}_status").eql?('accepted') && rejected_reason.present?
      public_send("#{target_column}_status=", STATUS[:rejected])
      public_send("#{target_column}_was_rejected=", public_send("#{target_column}_was_accepted"))
      public_send("#{target_column}_rejected_reason=", rejected_reason)
      public_send("#{target_column}_was_accepted=", public_send("#{target_column}_before"))
      public_send("remove_#{target_column}_was_accepted=", true) if carrierwave_column?(self.class) && public_send("#{target_column}_before").blank?
      public_send("remove_#{target_column}_before=", true) if carrierwave_column?(self.class)
      public_send("#{target_column}_before=", nil)
      public_send("#{target_column}_confirmed_at=", Time.current)
      save!(validate: false)
    end

    # 非承認された値を承認する
    # @params [Symbol] target_column 対象カラム
    def target_rejected_to_accepted!(target_column)
      return unless public_send("#{target_column}_status").eql?('rejected')
      public_send("#{target_column}_status=", STATUS[:accepted])
      public_send("#{target_column}_before=", public_send("#{target_column}_was_accepted"))
      public_send("#{target_column}_was_accepted=", public_send("#{target_column}_was_rejected"))
      public_send("remove_#{target_column}_was_rejected!") if carrierwave_column?(self.class)
      public_send("#{target_column}_was_rejected=", nil)
      public_send("#{target_column}_rejected_reason=", nil)
      public_send("#{target_column}_confirmed_at=", Time.current)
      save!(validate: false)
    end

    # 承認済みの値を強制的に非承認する
    # @params [Symbol] 対象カラム
    # @params [String] rejected_reason 非承認理由
    def target_force_rejected!(target_column, rejected_reason)
      return unless public_send("#{target_column}_was_accepted").present? && (public_send("#{target_column}_pending?") || public_send("#{target_column}_rejected?"))
      public_send("#{target_column}_was_rejected=", public_send("#{target_column}_was_accepted"))
      public_send("#{target_column}_rejected_reason=", rejected_reason)
      public_send("remove_#{target_column}_was_accepted!") if carrierwave_column?(self.class)
      public_send("#{target_column}_was_accepted=", nil)
      public_send("#{target_column}_admin_user_id=", nil)
      save!(validate: false)
    end

    # 非承認済みの値を強制的に承認する
    # @params [Symbol] 対象カラム
    def target_force_accepted!(target_column)
      return unless public_send("#{target_column}_was_rejected").present? && (public_send("#{target_column}_pending?") || public_send("#{target_column}_accepted?"))
      public_send("#{target_column}_before=", public_send("#{target_column}_was_accepted"))
      public_send("#{target_column}_was_accepted=", public_send("#{target_column}_was_rejected"))
      public_send("remove_#{target_column}_was_rejected!") if carrierwave_column?(self.class)
      public_send("#{target_column}_was_rejected=", nil)
      public_send("#{target_column}_rejected_reason=", nil)
      public_send("#{target_column}_admin_user_id=", nil)
      save!(validate: false)
    end
  end

  class_methods do
    # カラムに承認フローを追加する
    # @params [Array<Symble>] 承認の必要なカラム名(可変長)
    # @return [Boolean] 成功
    # @raise 必須カラムがないとき
    def approvable(*targets)
      targets.each do |target|
        next unless required_column_exists?(target)
        define_approvable_enums(target)
        define_callback_before_update_the_new_value(target)
        define_validation(target)
        create_has_many(target)
      end
      define_approval_values
    end

    private

    # 必須カラムチェック
    def required_column_exists?(target)
      return true if REQUIRED_COLUMN.subset?(attribute_names.map { |m| m.sub(target.to_s, 'target') }.to_set)
      required_column = REQUIRED_COLUMN.to_a.map { |m| m.gsub('target', target.to_s) }.join(', ')
      Rails.logger.warn "Approvable 必須カラムが定義されていません。 必須カラム: #{required_column}"
      false
    end

    # Enum定義
    def define_approvable_enums(target)
      class_eval do
        approvable_columns << target
        approvable_enum_hash = STATUS
        enum "#{target}_status" => approvable_enum_hash, _prefix: target
      end
    end

    # 承認フローを必要とするカラムを更新する時のコールバック
    # 変更された値があればステータスはpending、なければblankedにする
    def define_callback_before_update_the_new_value(target)
      class_eval do
        before_save do
          changes.each do |change_column_name, values|
            next unless change_column_name == target.to_s
            public_send("#{target}_status=", values.last.present? ? STATUS[:pending] : STATUS[:blanked])
            public_send("#{target}_confirmed_at=", nil)
          end
        end
      end
    end

    # Enum定義に紐づくバリデーション
    def define_validation(target)
      class_eval do
        validates :"#{target}_status", inclusion: { in: public_send("#{target}_statuses").keys }
        validates :"#{target}_status", inclusion: { in: %w(blanked) }, if: -> { public_send("#{target}?").nil? }
        validates :"#{target}_status", inclusion: { in: %w(pending) }, if: -> { public_send("#{target}_confirmed_at?").nil? }
        validates :"#{target}_status", inclusion: { in: %w(accepted rejected) }, if: :"#{target}_confirmed_at?"
        validates :"#{target}_status", inclusion: { in: %w(accepted) }, if: :"#{target}_was_accepted_changed?"
        validates :"#{target}_status", inclusion: { in: %w(rejected) }, if: :"#{target}_was_rejected_changed?"
      end
    end

    # approval_valuesを定義
    # ステータスに応じてHashを返す
    # @return [Hash] {:#{target} => {value, was_accepted, was_rejected, status, before}, #{target}_my_page, #{target}_opp_profile }
    def define_approval_values
      class_eval do
        def approval_values
          approvable_columns.each_with_object({}) do |target, h|
            h[target] = approval_value(target)
            h["#{target}_my_page"] = (status(target) == 'pending' ? value(target) : was_accepted(target)).to_s
            h["#{target}_opp_profile"] = was_accepted(target).to_s unless target == :comment
            h["#{target}_opp_profile"] = was_accepted(target).to_s.presence || I18n.t('user_profile.default_comment') if target == :comment
          end
        end
      end
    end

    # approval_valuesを定義
    # has_manyを定義
    def create_has_many(target)
      class_eval do
        belongs_to :"#{target}_admin_user", class_name: 'Admin::User', foreign_key: :"#{target}_admin_user_id", optional: true
      end
    end
  end

  def approval_value(target)
    {
      value: value(target).to_s,
      was_accepted: was_accepted(target).to_s,
      was_rejected: was_rejected(target).to_s,
      status: status(target),
      before: before(target).to_s,
      rejected_reason: rejected_reason(target),
      confirmed_at: confirmed_at(target) ? confirmed_at(target).strftime('%Y-%m-%d %H:%M:%S') : nil
    }
  end

  define_method(:value) do |target|
    public_send(target) if approvable_columns.include?(target.to_sym)
  end

  REQUIRED_COLUMN.to_a.map { |m| m.gsub(/\Atarget_/, '') }.each do |column_name|
    define_method(column_name) do |target|
      return NoMethodError unless approvable_columns.include?(target.to_sym)
      public_send("#{target}_#{column_name}")
    end
  end
  [:rejected!, :accepted!].each do |column_name|
    define_method(column_name) do |target|
      return NoMethodError unless approvable_columns.include?(target.to_sym)
      public_send("#{target}_#{column_name}")
    end
  end

  def carrierwave_column?(target_class)
    class_eval do
      return true if [ProfileImage, UserAgeCertification, UserIncomeCertification].include?(target_class)
      false
    end
  end
end
# rubocop:enable Metrics/ModuleLength
