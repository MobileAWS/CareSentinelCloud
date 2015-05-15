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
  get 'sites' => 'authentication#sites'

  get '/' => 'navigate#login'
  get '/:userrole' => 'navigate#login'
  get '/:userrole/home' => 'navigate#home'
  get '/:userrole/view' => 'navigate#view'
  get '/:userrole/add_edit' => 'navigate#add_edit'
  get '/:userrole/details' => 'navigate#details'



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
      post 'addSiteUser' => 'rest/user#addSite'
      post 'removeSiteUser' => 'rest/user#removeSite'
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

  resources :device do
    collection do
      get 'list' => 'rest/device#list'
      post 'create' => 'rest/device#create'
      post 'update' => 'rest/device#update'
      post 'delete' => 'rest/device#delete'
      get 'suggestions' => 'rest/device#suggestions'
      post 'createdevices' => 'rest/device#createDevices'
      post 'editdevices' => 'rest/device#editDevices'
      post 'addproperties' => 'rest/device#addProperties'
      get  ':id/properties' => 'caregiver#device_properties'
    end
  end

  # Admin pages routes

  # Caregiver pages routes

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
