module Versions
  module V1
    module UserArticle
      extend ActiveSupport::Concern
      included do
        namespace :user do
          namespace :article do

            desc '投稿する'
            params do
              requires :auth_token, type: String, desc: '認証トークン'
              requires :body, type: String, desc: '本文'
            end
            post :post, jbuilder: 'v1/users/login' do
							authenticated!
							db_transaction do
								current_user.articles.create!(params.slice(:body))
							end
            end

          end
        end
      end
    end
  end
end
