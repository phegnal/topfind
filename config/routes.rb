ActionController::Routing::Routes.draw do |map|

  map.site_search  'search', :controller => 'front', :action => 'search'
  map.root :controller => 'front', :action => 'index'
  map.connect 'documentations/admin', :controller => 'documentations', :action => 'admin'
  map.connect 'documentation', :controller => 'documentations', :action => 'index'
  map.connect 'license', :controller => 'documentations', :action => 'license'
  map.connect  'about', :controller => 'documentations', :action => 'about'  
  map.connect  'download', :controller => 'documentations', :action => 'download' 
  map.connect  'api', :controller => 'documentations', :action => 'api'
  map.connect 'contribute', :controller => 'imports', :action => 'index'
  
  map.connect 'interactions/:id', :controller => 'cleavages', :action => 'psicquicshow'


  map.connect 'ntermini/', :controller => 'nterms', :action => 'index'
  map.connect 'ctermini/', :controller => 'cterms', :action => 'index'

  # map.connect '/proteins/:function', :controller => 'proteins', :action => 'index'    
  # map.connect '/proteins/:function/page/:page', :controller => 'proteins', :action => 'index'  
  map.connect '/proteins/page/:page', :controller => 'proteins', :action => 'index'
  map.connect 'proteins/filter', :controller => 'proteins', :action => 'index'
  
  map.connect 'protein/:id/filter', :controller => 'proteins', :action => 'filter'
  map.connect 'proteins/:id/:chain/', :controller => 'proteins', :action => 'show'
  map.connect 'proteins/:id/:chain/filter', :controller => 'proteins', :action => 'filter'
  
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
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
