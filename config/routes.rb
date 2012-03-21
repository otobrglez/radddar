Radddar::Application.routes.draw do

  # Landing page
  root :to => "app#landing"
  match '/reminder', :to => "app#reminder", :as => "reminder"

  # The Radddar App ;)
  match '/app', :to => "app#app", :as => "app"
  match '/live', :to => "app#live", :as => "live"

  # Signin / Signout
  #match '/facebook' => redirect('/auth/facebook')
  #match '/twitter' => redirect('/auth/twitter')
  match '/auth/:provider/callback', :to => 'sessions#callback', :as => "auth"
  match '/signout', :to => 'sessions#destroy', :as => 'signout'
  match '/auth', :to => "sessions#pusher_auth", :as => "pusher_auth"

  # Current user
  match '/current_user', :to => "app#current_user_action", :as => "current_user"
  match '/profile_update', :to => "app#profile_update", :as => "profile_update"
  
  # Status
  match '/status_form', :to => "app#status_form", :as => "status_form"
  match '/status_set', :to => "app#status_set", :as => "status_set"
  match '/status_reload', :to => "app#status_reload", :as => "status_reload"

  # Users
  match '/profile/:id', :to => "app#profile", :as => "profile"
  match '/swap', :to => "app#swap", :as => "swap"

  # Notification
  match '/notify/:id', :to => "app#notify", :as => "notify"
  match '/remove_note/:stamp', :to => "app#remove_note", :as => "remove_note"

  # Chat
  match '/reload_chat_feed', :to => "app#reload_chat_feed", :as => "reload_chat_feed"
  match '/chat/:id', :to => "app#chat", :as => "chat"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
