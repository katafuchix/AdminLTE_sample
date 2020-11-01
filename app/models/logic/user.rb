# ユーザのロジックを定義
# 必要なメソッドは、logic/userのモジュールをincludeして定義します
module Logic
  module User
    extend ActiveSupport::Concern

    included do
      # 他のモデルに紐づいているものはUser*
      #include Logic::User::UserFavorite
      include Logic::User::UserPayment
      #include Logic::User::UserPointPayment
      include Logic::User::UserNotification
      include Logic::User::UserMatchMessage
      #include Logic::User::UserInvite
      #include Logic::User::AdminIssuedInviteCode
      #include Logic::User::UserSmsVerification
      include Logic::User::UserAssociation
      #include Logic::User::UserLoginBonus
      #include Logic::User::UserBlock
      #include Logic::User::UserBlockedPhone
      include Logic::User::UserProfile


      # Userに対して直接メソッドを定義しているものはprefixなし
      include Logic::User::Create
      extend Logic::User::Create::ClassMethods
      include Logic::User::Update
      extend Logic::User::Update::ClassMethods
      include Logic::User::Destroy
      include Logic::User::ProfileSearch
      include Logic::User::Search
      include Logic::User::Ransack
      include Logic::User::InputFormCondition
      include Logic::User::Status
      include Logic::User::Notification
      include Logic::User::Point
      include Logic::User::Aggregate

    end

    # 性別ユーザーのインスタンスに変更する
    # @return [Model] MaleUserまたはFemaleUser
    def grant_gender
      case sex
      when 'male' then
        becomes(::UserSex::MaleUser)
      when 'female' then
        becomes(::UserSex::FemaleUser)
      else
          ; self
      end
    end

    # Userテーブルからレコードを再取得する(usersテーブルの更新処理に必要)
    # @return [Model] User
    def raw_user_record
      ::User.find(id)
    end
  end
end
