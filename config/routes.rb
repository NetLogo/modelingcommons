ActionController::Routing::Routes.draw do |map|
  map.resources :attachments

  map.resources :versions


  map.resources :collaborator_types

  map.resources :projects, :member => { :download => [:get]}

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up ''
  # -- just remember to delete public/index.html.

  map.connect '', :controller => "account", :action => "mypage"

  # map.connect '/browse/model_contents/:filename', :controller => 'browse', :action => 'model_contents'

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  map.connect '/browse/model_contents/:dirname/:extensionname.:format', :controller => 'browse', :action => 'extension'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end
