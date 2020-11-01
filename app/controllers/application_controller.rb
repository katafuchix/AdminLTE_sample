class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

    # 例外処理
    unless Rails.env.development?
      rescue_from Exception, with: :render_500
      rescue_from ActiveRecord::RecordNotFound, with: :render_404
      rescue_from ActionController::RoutingError, with: :render_404
    end

    # ログイン後のリダイレクト先を指定
    # @param [Model] resource deviseがマッピングされたモデル
    # @return [String] リダイレクト先
    def after_sign_in_path_for(resource)
      flash[:notice] = "ログインに成功しました" #　
      admin_index_path
    end

    def after_sign_out_path_for(resource)
      new_admin_user_session_path
    end

    def render_404(e = nil)
      logger.info "Rendering 404 with exception: #{e.message}" if e
      if request.xhr?
        render json: { error: '404 error' }, status: 404
      else
        render template: 'errors/error_404', status: 404, layout: 'application', content_type: 'text/html'
      end
    end

    def render_500(e = nil)
      logger.info "Rendering 500 with exception: #{e.message}" if e
      #Bugsnag.auto_notify(e) if e.is_a?(Exception) && Object.const_defined?(:Bugsnag)
      #SlackService.exception(request.url, e)
      if request.xhr?
        render json: { error: '500 error' }, status: 500
      else
        render template: 'errors/error_500', status: 500, layout: 'application', content_type: 'text/html'
      end
    end
end
