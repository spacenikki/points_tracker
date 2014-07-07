Rails.application.routes.draw do
  get 'tracker/index'

  get '/tracker/add_ff'
  post '/tracker/add_ff'

  post '/tracker/adding_ff_now'

  devise_for :users
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'tracker#index'

  get '/tracker' => 'tracker#index'
  get '/tracker/show'
  # get '/tracker/get_mileage'

  # pass detail.id from view to here, now u rename it as :id id -> then when detail.id got pass from view, it will be sent to function get_mleage, named "id", can be retrieved by calling params[:id]
  post "/tracker/get_mileage/:id" => "tracker#get_mileage"  

  # without the => "tracker#get_mileage"  -> it will break -> cuz there is no exact route as "/tracker/get_mileage/:id" -> there is only "/tracker/get_mileage" 

  get '/tracker/destroy/:id' => "tracker#destroy"

  # get '/tracker/show/:id' -> only need this when need to pass user id , since devise remember current_user.id , so no need to pass anymore
  
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
