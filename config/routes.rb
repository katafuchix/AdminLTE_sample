Rails.application.routes.draw do
  get 'test/starter'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  get '/' => 'admin/index#index'

  #devise_for 'admin/users'
  #devise_for :admin_users
  devise_for 'admin/users', controllers: {
    sessions: 'admin_users/sessions'
  }

  devise_scope 'admin/users' do
    get '/' => 'admin_users/sessions#new'
    get '/admin_users/sign_out' => 'admin_users/sessions#destroy'
  end

  namespace :admin do
    get '/' => 'index#index'
    get 'index' => 'index#index'
    resources :admin_users, controller: :manage_roles

    resource :app_configs, only: %i(edit update)

    Master.master_routes.keys.each do |type|
      resources type, controller: :masters, type: type.classify
    end

    resources :users, only: [:index, :show, :destroy, :update, :edit] do
      member do
        patch :update_profile
        put :purchase_payingmember
        put :purchase_point
        put :add_relation_count
        put :send_notification
        put :restore_soft_destroy
        put :toggle_search_status
        delete :profile_image_destroy
      end
    end
  end

  mount Versions::V1::Api => '/'
  mount GrapeSwaggerRails::Engine => '/api/swagger'

end
