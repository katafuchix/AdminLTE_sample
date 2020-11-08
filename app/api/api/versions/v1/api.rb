module Versions
  module V1
    class Api < Grape::API
      version 'v1', using: :path
      format :json
      formatter :json, Grape::Formatter::Jbuilder
      prefix :api

      # エラー対応
      rescue_from :all, backtrace: true
      error_formatter :json, ::MediaSite::ErrorFormatter

      include ::MediaSite::Util
      include ::MediaSite::Auth

      include ::Versions::V1::TaskDisplays
      include ::Versions::V1::TestUser
      include ::Versions::V1::TestUserProfile

      include ::Versions::V1::ProfileMasters
      include ::Versions::V1::ProfileImages
      include ::Versions::V1::UserProfiles
      include ::Versions::V1::UserRelations

      include ::Versions::V1::UserArticle

      GrapeDeviseTokenAuth.setup! do |config|
        config.authenticate_all = true
      end


      # :nocov:
      if Rails.env.development?
        add_swagger_documentation add_version: true
      end
      # :nocov:
    end
  end
end
