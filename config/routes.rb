ActionController::Routing::Routes.draw do |map|

  map.site_search  'search', :controller => 'front', :action => 'search'
  map.root :controller => 'front', :action => 'index'
  map.connect 'documentation/', :controller => 'documentations', :action => 'index'
  map.connect 'documentations/admin', :controller => 'documentations', :action => 'admin'
  map.connect 'license', :controller => 'documentations', :action => 'license'
  map.connect  'about', :controller => 'documentations', :action => 'about'  
  map.connect  'download', :controller => 'documentations', :action => 'download' 
  map.connect  'api', :controller => 'documentations', :action => 'api'
  map.connect 'contribute/', :controller => 'imports', :action => 'index'
  map.connect 'proteins/blabla', :controller => 'proteins', :action => 'blabla'
  map.connect 'proteins/tryouts', :controller => 'proteins', :action => 'tryouts'
  map.connect 'proteins/tryouts2', :controller => 'proteins', :action => 'tryouts2'
  
  map.connect 'interactions/:id', :controller => 'cleavages', :action => 'psicquicshow'


  map.connect 'ntermini/', :controller => 'nterms', :action => 'index'
  map.connect 'ctermini/', :controller => 'cterms', :action => 'index'

  # map.connect '/proteins/:function', :controller => 'proteins', :action => 'index'    
  # map.connect '/proteins/:function/page/:page', :controller => 'proteins', :action => 'index'  
  map.connect '/proteins/page/:page', :controller => 'proteins', :action => 'index'
  map.connect 'proteins/filter', :controller => 'proteins', :action => 'index'
  
  map.connect 'proteins/:id/filter', :controller => 'proteins', :action => 'filter'
  map.connect 'proteins/:id/:chain', :controller => 'proteins', :action => 'show'
  map.connect 'proteins/:id/:chain/filter', :controller => 'proteins', :action => 'filter'
  # map.connect 'proteins/filter', :controller => 'proteins', :action => 'index' 
  
  #csv exports
  map.connect 'cleavages/export', :controller => 'cleavages', :action => 'export'
  map.connect 'nterms/export', :controller => 'nterms', :action => 'export'
  map.connect 'cterms/export', :controller => 'cterms', :action => 'export'
  map.connect 'evidences/export', :controller => 'evidences', :action => 'export'
   
  map.connect 'api/get/protein/:id/', :controller => 'proteins', :action => 'apiget'
  map.connect 'api/search/proteins', :controller => 'proteins', :action => 'apisearch'
  map.connect 'api/search/ntermini', :controller => 'nterms', :action => 'apisearch'
  map.connect 'api/search/ctermini', :controller => 'cterms', :action => 'apisearch'
  map.connect 'api/search/cleavages', :controller => 'cleavages', :action => 'apisearch'
    
  Hobo.add_routes(map)
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
