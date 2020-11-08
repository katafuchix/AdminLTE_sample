module Versions
  module V1
    module TaskDisplays
      extend ActiveSupport::Concern
      included do
        namespace :tasks do
          namespace :displays do
            desc 'タスク一覧を取得する'
            params do
              requires :auth_token, type: String, desc: '認証トークン'
            end
            get '', jbuilder: 'v1/task_displays/index' do
              authenticated!
              @tasks = Task.all
            end

            desc "個別タスクの取得"
            params do
              requires :id, type: Integer
            end
            # http://localhost:3000/api/1/task_displays/{:id}
            get ':id', jbuilder: 'v1/task_displays/detail' do
              @task = Task.find(params[:id])
            end

          end
        end
      end
    end
  end
end
