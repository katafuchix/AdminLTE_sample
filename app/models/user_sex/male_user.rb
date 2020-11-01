module UserSex
  class MaleUser < ::User
    include ::Logic::User::UserPayment::MaleUser
    #include ::Logic::User::UserMatchMessage::MaleUser
    include ::Logic::User::ProfileSearch::MaleUser
    include ::Logic::User::InputFormCondition::MaleUser
  end
end
