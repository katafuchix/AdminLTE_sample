module Logic
  module UserRelation
    extend ActiveSupport::Concern
    def validate_relation_point
      return if skip_relation_point?
      return unless lack_relation_point?
      errors[:base] << I18n.t('api.errors.relation_point')
    end

    # いいねポイント消費をスキップするか
    # @return [Boolean] 判定
    def skip_relation_point?
      user.raw_user_record.user_profile.female? || skipped?
    end

    # いいねポイントが不足しているか
    # @return [Boolean] 判定
    def lack_relation_point?
      manage_point = ::ManagePoint.find_by(key: 'relation')
      return false if manage_point.blank? || manage_point.point == 0
      user.remain_relation_count + user.relation_point < manage_point.point
    end

    # いいねポイントを消費する
    # @return バリデーションエラー
    def use_relation_point!
      return if skip_relation_point?
      return if lack_relation_point?
      manage_point = ::ManagePoint.find_by(key: 'relation')
      u = user.raw_user_record
      remain_relation_count_diff = user.remain_relation_count - manage_point.point
      u.update!(remain_relation_count: remain_relation_count_diff > 0 ? remain_relation_count_diff : 0)
      u.update!(relation_point: user.relation_point - remain_relation_count_diff.abs) if remain_relation_count_diff < 0
      user.reload
    end

    def validate_relation_message_point
      return unless message.present?
      return unless lack_relation_message_point?
      errors[:base] << I18n.t('api.errors.use_point')
    end

    # いいねメッセージを送るpatersポイントが不足しているか
    # @return [Boolean] 判定
    def lack_relation_message_point?
      manage_point = ::ManagePoint.find_by(key: 'relation_message')
      return false if manage_point.blank? || manage_point.point == 0
      user.pater_point < manage_point.point
    end

    # いいねメッセージポイントバリデーション
    # @return バリデーションエラー
    def use_relation_message_point!
      return unless message.present?
      return if lack_relation_message_point?
      manage_point = ::ManagePoint.find_by(key: 'relation_message')
      user.use_point!(manage_point.point) if manage_point
    end

    # ポイント消費スキップ条件
    # @return [Boolean] スキップ判定
    def skip_use_point?
      find_pickup || find_reverse_relation || skip_use_relation_point
    end

    # usersテーブルのいいね数の更新
    def refresh_user_relation_count!
      user.raw_user_record.update!(outcomming_relations_count: user.outcomming_active_relations.count)
      target_user.raw_user_record.update!(incomming_relations_count: target_user.incomming_active_relations.count,
                                          within_month_incomming_relation_count: target_user.month_incomming_relation_count,
                                          within_week_incomming_relation_count: target_user.week_incomming_relation_count)
    end

    # 逆向きのいいねを返す
    # @return [UserRelation] 逆向きのいいね
    def find_reverse_relation
      target_user.outcomming_active_relations.find_by(target_user: user)
    end

    # いいねに対応するピックアップを返す
    # @return [UserPickup] ピックアップ
    def find_pickup
      user.outcomming_pickups.find_by(slice(:target_user_id))
    end

    # いいねがactiveになったらPush通知送信 and メール送信
    def send_relation_notification
      return unless become_active?
      return if skip_notification?
      UserRelationMailer.create(self).deliver_later if target_user.sendable_relation_mail?
      target_user.send_push_notification('user_relation_mailer.create.push.body') if target_user.user_notify.relation_push_notify
    end

    # マッチング処理を行う
    def matching_if_need
      return unless become_active?
      return unless find_reverse_relation.present?
      create_matching
    end

    # マッチングを作成
    # @return [UserMatch] ユーザーのマッチング
    def create_matching
      matching = target_user.user_matchs.create!(target_user: user)
      update!(user_match: matching)
      find_reverse_relation.update!(user_match: matching)
      matching.reset_read_count!
      matching.create_match_message_from_relation
      matching.send_match_notification unless skip_notification?
    end

    # 承認済みのいいねメッセージを取得
    def accepted_message
      return nil unless message_status == 'accepted'
      message_was_accepted
    end

    private

    # ピックアップを削除する
    def destroy_pickup
      find_pickup.destroy
    end

    # 処理によりアクティブになったか
    def become_active?
      (id_changed? || active_changed?) && active
    end

    # 通知をスキップするか
    def skip_notification?
      !skip_notification.nil? && skip_notification
    end
  end
end
