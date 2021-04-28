Rails.application.routes.draw do
  # Disable PUT for now since rails sends these :update and they aren't really the same thing.
  def put(*_args); end

  routing_helper = Insights::API::Common::Routing.new(self)
  prefix = "api"

  prefix = File.join(ClowderConfig.instance["PATH_PREFIX"], ClowderConfig.instance["APP_NAME"]).gsub(/^\/+|\/+$/, "")

  get "/health", :to => "status#health"

  scope :as => :api, :module => "api", :path => prefix do
    routing_helper.redirect_major_version("v1.0", prefix)

    namespace :v1x0, :path => "v1.0" do
      get "/openapi.json", :to => "root#openapi"
      post "graphql" => "graphql#query"

      concern :taggable do
        post      :tag,   :controller => :taggings
        post      :untag, :controller => :taggings
        resources :tags,  :controller => :taggings, :only => [:index]
      end

      resources :service_credentials, :only => [:index, :show]
      resources :service_credential_types, :only => [:index, :show]

      resources :service_instances, :only => [:index, :show]
      resources :service_offering_icons,  :only => [:index, :show] do
        get "icon_data", :to => "service_offering_icons#icon_data"
      end

      resources :service_inventories, :only => [:index, :show], :concerns => [:taggable]

      resources :service_offering_nodes, :only => [:index, :show]

      resources :service_offerings, :only => [:index, :show] do
        post "applied_inventories_tags", :to => "service_offerings#applied_inventories_tags"
        post "order", :to => "service_offerings#order"
        resources :service_instances,      :only => [:index]
        resources :service_offering_nodes, :only => [:index]
        resources :service_plans,          :only => [:index]
      end
      resources :service_plans, :only => [:index, :show]
      resources :sources,                  :only => [:index, :show] do
        resources :service_instances,      :only => [:index]
        resources :service_inventories,    :only => [:index]
        resources :service_offering_nodes, :only => [:index]
        resources :service_offerings,      :only => [:index]
        resources :service_plans,          :only => [:index]
        resources :tasks,                  :only => [:index]
      end
      patch '/sources/:source_id/refresh', :to => "sources#refresh", :as => 'refresh'

      resources :tags, :only => [:index]
      resources :tasks, :only => [:index, :show, :update]
    end
  end

  scope :as => :internal, :module => "internal", :path => "internal" do
    routing_helper.redirect_major_version("v1.0", "internal", :via => [:get])

    namespace :v1x0, :path => "v1.0" do
      resources :sources, :only => [:update]
      resources :tenants, :only => [:index, :show]
    end
  end

  match "*path", :to => "api/root#invalid_url_error", :via => ActionDispatch::Routing::HTTP_METHODS
end
