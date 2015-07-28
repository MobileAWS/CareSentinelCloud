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
  post '/:userrole/home' => 'navigate#home'
  get '/:userrole/view' => 'navigate#view'
  get '/:userrole/add_edit' => 'navigate#add_edit'
  get '/:userrole/details' => 'navigate#details'

  get '/:userrole/download_caregivers' => 'caregiver#download_caregivers'



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
      post 'addCustomerId' => 'rest/user#addCustomerId'
      post 'removeCustomerId' => 'rest/user#removeCustomerId'
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

  resources :property do
    collection do
      get 'list' => 'rest/property#list'
      post 'create' => 'rest/property#create'
      post 'update' => 'rest/property#update'
      post 'delete' => 'rest/property#delete'
    end
  end

  resources :customer do
    collection do
      get 'list' => 'rest/customer#list'
      post 'create' => 'rest/customer#create'
      post 'update' => 'rest/customer#update'
      post 'delete' => 'rest/customer#delete'
      get 'suggestions' => 'rest/customer#suggestions'
    end
  end

  resources :devicemapping do
    collection do
      get 'list' => 'rest/device_mapping#list'
      post 'create' => 'rest/device_mapping#create'
      post 'update' => 'rest/device_mapping#update'
      post 'delete' => 'rest/device_mapping#delete'
      get 'suggestions' => 'rest/device_mapping#suggestions'
      get 'properties_suggestions' => 'rest/device_mapping#properties_suggestions'
    end
  end

  resources :device do
    collection do
      post 'create' => 'rest/device#create'
      post 'update' => 'rest/device#update'
      post 'delete' => 'rest/device#delete'
      get 'suggestions' => 'rest/device#suggestions'
      get 'suggestions_hw' => 'rest/device#suggestions_hw'
      post 'createdevices' => 'rest/device#createDevices'
      post 'editdevices' => 'rest/device#editDevices'
      post 'addproperties' => 'rest/device#addProperties'
      post  ':id/changestatus' => 'rest/device#change_status'
      post ':id/properties' => 'rest/device#properties'
      post ':device_id/properties_report/:property_id' => 'rest/device#properties_report'
      post ':device_id/average_report/:property_id' => 'rest/device#average_report'
      get  ':id/properties' => 'caregiver#device_properties'
      get 'download' => 'caregiver#download_devices'
      get 'export_historic_report' => 'caregiver#export_historic_report'
      get 'export_average_report' => 'caregiver#export_average_report'
    end
  end

  resources :site_config do
    collection do
      post 'purge_days' => 'rest/site_config#purge_days'
      post 'emails_purge' => 'rest/site_config#emails_purge'
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
