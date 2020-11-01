ADD_PRIVATE_LIST    = %w(Master::Job Master::AnnualIncome Master::HaveChild Master::Holiday Master::Marriage Master::EducationalBackground)
ADD_NOT_SELECT_LIST = %w(Master::DrinkingHabit Master::ExpectSupportMoney Master::FirstDateCost Master::Personality Master::RequestUntilMeet Master::SmokingHabit)
{
  Master::Job =>                   %w[会社員 経営者・役員 医師 弁護士 公認会計士 学生 フリーター 公務員 事務員 大手商社 外資金融 大手企業 大手外資 クリエイター IT関連 客室乗務員 芸能・モデル アパレル・ショップ イベントコンパニオン 受付 秘書 看護師 保育士 上場企業 金融 コンサル 調理師・栄養士 教育関連 食品関連 製薬 保険 不動産 WEB業界 接客業 美容関係 エンターテインメント 旅行関係 ブライダル 福祉・介護 広告 マスコミ],
  Master::AnnualIncome =>          %w[5000万円以上 3000万円〜5000万円 2000万円〜3000万円 1500万円〜2000万円 1000万円〜1500万円 800万円〜1000万円 600万円〜800万円 400万円〜600万円 400万円未満],
  Master::DrinkingHabit =>         %w[飲まない 飲む ときどき飲む],
  Master::ExpectSupportMoney =>    %w[50万円以上 40万円〜50万円 30万円〜40万円 20万円〜30万円 10万円〜20万円 5万円〜10万円 3万円〜5万円 1万円〜3万円 1万円未満],
  Master::Figure =>                %w[スリム やや細め 普通 グラマー 筋肉質 ややぽっちゃり 太め],
  Master::FirstDateCost =>         %w[3000円未満 3000円〜5000円 5000円〜1万円 1万円〜2万円 2万円〜3万円 3万円以上],
  Master::HaveChild =>             %w[なし 1人 2人 3人以上],
  Master::Holiday =>               %w[土日 平日 不定期],
  Master::Marriage =>              %w[未婚 既婚 離婚 死別],
  Master::Personality =>           %w[優しい 素直 決断力がある 穏やか 親しみやすい 明るい インドア アウトドア 真面目 知的 誠実 几帳面 楽観的 照れ屋 いつも笑顔 上品 落ち着いている 謙虚 厳格 思いやりがある さびしがり 社交的 冷静沈着 好奇心旺盛 家庭的 仕事好き 責任感がある 面倒見がいい 話し上手 さわやか 行動的 合理的 負けず嫌い 面白い 熱い 気が利く マメ 大胆 寛容 気前がいい 天然と言われる 裏表がない マイペース 奥手 気分屋],
  Master::RequestUntilMeet =>      %w[マッチング後にまずは会いたい 気が合えば会いたい 条件が合えば会いたい メッセージ交換を重ねてから会いたい その他],
  Master::SmokingHabit =>          %w[吸わない 吸う ときどき吸う 非喫煙者の前では吸わない 相手が嫌ならやめる],
  Master::EducationalBackground => %w[短大・専門学校卒 高校卒 大学卒 大学院卒 その他],
  Master::ViolationCategory =>     %w[他サイトやビジネスへの勧誘 詐欺行為 商売利用目的 プロフィール項目の詐称 偽アカウント 不適切な登録内容 無断のドタキャン メッセージが攻撃的 ストーカー行為 卑猥な言動 個人情報交換後に連絡が途絶えた 窃盗行為 その他],
  Master::Prefecture =>            %w[東京都 神奈川県 埼玉県 千葉県 大阪府 京都府 兵庫県 奈良県 愛知県 岐阜県 三重県 福岡県 北海道 青森県 岩手県 宮城県 秋田県 山形県 福島県 茨城県 栃木県 群馬県 新潟県 富山県 石川県 福井県 山梨県 長野県 静岡県 滋賀県 和歌山県 鳥取県 島根県 岡山県 広島県 山口県 徳島県 香川県 愛媛県 高知県 佐賀県 長崎県 熊本県 大分県 宮崎県 鹿児島県 沖縄県 海外],
  Master::InquiryCategory =>       %w[お支払について 不快なユーザがいる サイトの技術的な問題について 利用規約・プライバシーポリシーについて 取材依頼等 その他 退会],
  Master::LeavingReason =>         %w[希望する条件に合う人とマッチングしない 希望する条件に合う人がいない 料金が高い 使い方がよくわからない いいお相手と巡り合うことができた プライバシー面に不安がある お相手とのやり取りで不快な思いをした アプリをあまり使わなくなった その他]
}.each do |_class_, names|
  if ADD_PRIVATE_LIST.include?(_class_.name)
    names = ['非公開', *names]
  elsif ADD_NOT_SELECT_LIST.include?(_class_.name)
    names = ['選択しない', *names]
  end
  attrs = names.map.with_index { |name, i = 1| {name: name, type: _class_.name, enabled: true, sort_order: i + 1} }
  _class_.seed_once(:name, :type, *attrs)
end
