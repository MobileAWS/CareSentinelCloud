Rails.application.routes.draw do

  get 'authentication/login'

  devise_for :users,
             path_names:{
              sign_in:'login',
              sign_out:'logout',
              sing_up:'register'
            },
            controllers:{
              sessions:'authentication',
              confirmations: 'overrides/devise_confirmation',
              passwords: 'overrides/devise_passwords'
            }

  get 'users/logout' => 'authentication#logout'

  resources :user do
    collection do
      post 'sign_up' => 'rest/user#register'
      get 'account_confirmed' => 'rest/user#confirmDone'
      get 'list' => 'rest/user#list'
      post 'delete' => 'rest/user#delete'
      post 'create' => 'rest/user#create'
      post 'update' => 'rest/user#update'
      get 'profile' => 'rest/user#profile'
      post 'resetPassword' => 'rest/user#resetPassword'
      post 'generateUserId' => 'rest/user#generateUserId'
    end
  end

  resources :site do
    collection do
      get 'list' => 'rest/site#list'
      post 'create' => 'rest/site#create'
      post 'update' => 'rest/site#update'
      post 'delete' => 'rest/site#delete'
      get 'suggestions' => 'rest/site#suggestions'
    end
  end

  # Admin pages routes

  get '/' => 'admin#login'
  get 'admin' => 'admin#login'
  get 'admin.html' => 'admin#login'
  get 'admin/home' => 'admin#home'
  get 'admin/view' => 'admin#view'
  get 'admin/add_edit' => 'admin#add_edit'
  get 'admin/details' => 'admin#details'

  get '/fonts/:resource_name', to: redirect(lambda{|params,req| "/assets/#{params[:resource_name]}"})

  #root 'main#index'
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#main'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
