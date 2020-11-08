module Versions
  module V1
    module ProfileMasters
      extend ActiveSupport::Concern
      included do
        namespace :profile_masters do
          desc '年収マスタを取得する'
          get :annual_income, jbuilder: 'v1/profile_masters/list' do
            @contents = Master::AnnualIncome.contents
          end

          desc '飲酒マスタを取得する'
          get :drinking_habit, jbuilder: 'v1/profile_masters/list' do
            @contents = Master::DrinkingHabit.contents
          end

          desc '希望支援金額マスタを取得する'
          get :expect_support_money, jbuilder: 'v1/profile_masters/list' do
            @contents = Master::ExpectSupportMoney.contents
          end

          desc '体型マスタを取得する'
          get :figure, jbuilder: 'v1/profile_masters/list' do
            @contents = Master::Figure.contents
          end

          desc '初回デート金額マスタを取得する'
          get :first_date_cost, jbuilder: 'v1/profile_masters/list' do
            @contents = Master::FirstDateCost.contents
          end

          desc '子供有無マスタを取得する'
          get :have_child, jbuilder: 'v1/profile_masters/list' do
            @contents = Master::HaveChild.contents
          end

          desc '休日マスタを取得する'
          get :holiday, jbuilder: 'v1/profile_masters/list' do
            @contents = Master::Holiday.contents
          end

          desc '結婚有無マスタを取得する'
          get :marriage, jbuilder: 'v1/profile_masters/list' do
            @contents = Master::Marriage.contents
          end

          desc '出会うまでの希望マスタを取得する'
          get :request_until_meet, jbuilder: 'v1/profile_masters/list' do
            @contents = Master::RequestUntilMeet.contents
          end

          desc '喫煙マスタを取得する'
          get :smoking_habit, jbuilder: 'v1/profile_masters/list' do
            @contents = Master::SmokingHabit.contents
          end

          desc '県マスタを取得する'
          get :prefecture, jbuilder: 'v1/profile_masters/list' do
            @contents = Master::Prefecture.contents
          end

          desc '仕事マスタを取得する'
          get :job, jbuilder: 'v1/profile_masters/list' do
            @contents = Master::Job.contents
          end

          desc '性格マスタを取得する'
          get :personality, jbuilder: 'v1/profile_masters/list' do
            @contents = Master::Personality.contents
          end

          desc '学歴マスタを取得する'
          get :educational_background, jbuilder: 'v1/profile_masters/list' do
            @contents = Master::EducationalBackground.contents
          end

          desc '血液型マスタを取得する'
          get :blood, jbuilder: 'v1/profile_masters/list' do
            @contents = UserProfile.bloods.map.with_index do |b, i|
              { id: b[1], name: "#{b[0].upcase}型", sort_order: i }
            end
          end

          desc '身長のマスタを取得する'
          get :height, jbuilder: 'v1/profile_masters/list' do
            @contents = (Settings.height.minimum..Settings.height.maximum).collect do |height|
              { id: height, name: "#{height}cm" }
            end
          end
        end
      end
    end
  end
end
