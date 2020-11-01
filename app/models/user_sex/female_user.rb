module UserSex
  class FemaleUser < ::User
    include ::Logic::User::UserPayment::FemaleUser
    #include ::Logic::User::UserMatchMessage::FemaleUser
    include ::Logic::User::ProfileSearch::FemaleUser
    include ::Logic::User::InputFormCondition::FemaleUser
  end
end
