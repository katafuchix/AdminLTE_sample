class UserPayment < ApplicationRecord
  include Logic::UserPayment
  belongs_to :user
  delegate :user_profile, to: :user
  validates :start_at, presence: true
  validates :end_at, presence: true
  enum payment_type: %w(normal_charging premium_charging)
  before_create :set_next_term_start_at

  scope :enabled, lambda {
    where(enabled: true)
  }

  scope :user_profile_name_cont, lambda { |name|
    joins(user: :user_profile).where("user_profiles.name LIKE '%#{name}%'")
  }

  # できればtime_rangeは(a...b)と、終端を含まない方で投げたほうがいいです
  # Rangeを渡した場合の生成SQLが以下のようになる
  # (a..b) の場合 #=> WHERE next_term_start_at BETWEEN a AND b
  # (a...b)の場合 #=> WHERE (next_term_start_at >= a) AND (next_term_start_at < b)
  # # SQLの※BETWEENは終端を両方含む
  scope :next_term_start_at_in, -> (time_range) { where(next_term_start_at: time_range) }

  def self.ransackable_scopes(_auth_object = nil)
    %i(user_profile_name_cont)
  end

  def next_term!
    return unless next_term_start_at
    return unless start_at
    self.next_term_start_at = calc_next_term_start_at
    save!
  end

  private

  # called by before_create
  # レコード生成時に有料会員かつ3ヶ月以上の購入の場合、1ヶ月ごとにポイントを付与する必要がある
  # next_term_start_atカラムで次のポイント付与時刻を記録しておくことで素早くバッチ側でレコードを取得するように
  # また、バッチによってポイント付与処理をした際にトランザクション内でnext_term_start_atをさらに+1.monthすることで、処理済みフラグとみなす役目もある
  def set_next_term_start_at
    return unless normal_charging?
    return if next_term_start_at
    self.next_term_start_at = calc_next_term_start_at
  end

  # 現在のstart_atをend_atからnext_term_start_atを計算し、next_term_start_atを返却する
  def calc_next_term_start_at
    # next_term_start_atがnilの場合はcreate直後と思われるので、start_atを暫定的に基準日として使用
    now_start_point = next_term_start_at || start_at
    return nil unless now_start_point

    # start_atを基準として、直前のnext_term_start_atを超えるxヶ月目を探し当てる
    cnt = 1
    cnt += 1 while start_at + cnt.month < now_start_point + 1.month

    # もしend_atまで1ヶ月を切っていたら、それは配布対象外
    # 1ヶ月ちょうどのばあいは配布対象なので'>'とする
    # # Appleのレシートからend_atを抽出してるが、レシートの課金終了日時がなぜか1時間長いので、余裕を持たせて+4日以内にend_atが来ないかを判定(最大誤差が8/31に6ヶ月課金した場合で翌年2/28に作成されるレシートの期限8/31(3日と1時間))
    # # 本番DBを見る限り、end_atがstart_at+x.monthを下回る場合は存在しなかったので、この判断式で可とする
    return nil if start_at + cnt.month + 4.day > end_at

    start_at + cnt.month
  end
end
