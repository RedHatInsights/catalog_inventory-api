Rails.application.routes.draw do
  # Disable PUT for now since rails sends these :update and they aren't really the same thing.
  def put(*_args); end

  routing_helper = Insights::API::Common::Routing.new(self)
  prefix = "api"
  if ENV["PATH_PREFIX"].present? && ENV["APP_NAME"].present?
    prefix = File.join(ENV["PATH_PREFIX"], ENV["APP_NAME"]).gsub(/^\/+|\/+$/, "")
  end

  get "/health", :to => "status#health"

  scope :as => :api, :module => "api", :path => prefix do
    routing_helper.redirect_major_version("v3.0", prefix)
    routing_helper.redirect_major_version("v2.0", prefix)
    routing_helper.redirect_major_version("v1.0", prefix)

    namespace :v3x0, :path => "v3.0" do
      get "/openapi.json", :to => "root#openapi"
      post "graphql" => "graphql#query"

      concern :taggable do
        post      :tag,   :controller => :taggings
        post      :untag, :controller => :taggings
        resources :tags,  :controller => :taggings, :only => [:index]
      end

      resources :service_credentials, :only => [:index, :show]
      resources :service_credential_types, :only => [:index, :show]

      resources :service_instances, :only => [:index, :show] do
        resources :service_credentials, :only => [:index]
        resources :service_instance_nodes, :only => [:index]
      end
      resources :service_instance_nodes, :only => [:index, :show] do
        resources :service_credentials, :only => [:index]
      end
      resources :service_offering_icons,  :only => [:index, :show] do
        get "icon_data", :to => "service_offering_icons#icon_data"
      end

      resources :service_inventories, :only => [:index, :show], :concerns => [:taggable]

      resources :service_offering_nodes, :only => [:index, :show] do
        resources :service_credentials, :only => [:index]
      end

      resources :service_offerings, :only => [:index, :show], :concerns => [:taggable] do
        post "applied_inventories", :to => "service_offerings#applied_inventories"
        post "order", :to => "service_offerings#order"
        resources :service_credentials,    :only => [:index]
        resources :service_instances,      :only => [:index]
        resources :service_offering_nodes, :only => [:index]
        resources :service_plans,          :only => [:index]
      end
      resources :service_plans, :only => [:index, :show] do
        post "order", :to => "service_plans#order"
        resources :service_instances, :only => [:index]
      end
      resources :sources,                  :only => [:index, :show] do
        resources :service_instances,      :only => [:index]
        resources :service_instance_nodes, :only => [:index]
        resources :service_inventories,    :only => [:index]
        resources :service_offering_nodes, :only => [:index]
        resources :service_offerings,      :only => [:index]
        resources :service_plans,          :only => [:index]
      end
      resources :tags, :only => [:index, :show] do
        resources :service_inventories, :only => [:index]
        resources :service_offerings,   :only => [:index]
      end
      resources :tasks, :only => [:index, :show, :update]
    end

    namespace :v2x0, :path => "v2.0" do
      get "/openapi.json", :to => "root#openapi"
      post "graphql" => "graphql#query"

      concern :taggable do
        post      :tag,   :controller => :taggings
        post      :untag, :controller => :taggings
        resources :tags,  :controller => :taggings, :only => [:index]
      end

      resources :service_instances,       :only => [:index, :show] do
        resources :service_instance_nodes, :only => [:index]
      end
      resources :service_instance_nodes,  :only => [:index, :show]
      resources :service_offering_icons,  :only => [:index, :show] do
        get "icon_data", :to => "service_offering_icons#icon_data"
      end
      resources :service_inventories,     :only => [:index, :show], :concerns => [:taggable]
      resources :service_offering_nodes,  :only => [:index, :show]
      resources :service_offerings,       :only => [:index, :show], :concerns => [:taggable] do
        post "applied_inventories", :to => "service_offerings#applied_inventories"
        post "order", :to => "service_offerings#order"
        resources :service_instances,      :only => [:index]
        resources :service_offering_nodes, :only => [:index]
        resources :service_plans,          :only => [:index]
      end
      resources :service_plans, :only => [:index, :show] do
        post "order", :to => "service_plans#order"
        resources :service_instances, :only => [:index]
      end
      resources :sources,                  :only => [:index, :show] do
        resources :service_instances,      :only => [:index]
        resources :service_instance_nodes, :only => [:index]
        resources :service_inventories,    :only => [:index]
        resources :service_offering_nodes, :only => [:index]
        resources :service_offerings,      :only => [:index]
        resources :service_plans,          :only => [:index]
      end
      resources :tags, :only => [:index, :show] do
        resources :service_inventories, :only => [:index]
        resources :service_offerings,   :only => [:index]
      end
      resources :tasks, :only => [:index, :show, :update]
    end

    namespace :v1x0, :path => "v1.0" do
      get "/openapi.json", :to => "root#openapi"
      post "graphql" => "graphql#query"

      resources :service_instances,        :only => [:index, :show] do
        resources :service_instance_nodes, :only => [:index]
      end
      resources :service_instance_nodes,  :only => [:index, :show]
      resources :service_offering_icons,  :only => [:index, :show] do
        get "icon_data", :to => "service_offering_icons#icon_data"
      end
      resources :service_inventories,     :only => [:index, :show] do
        resources :tags, :only => [:index]
      end
      resources :service_offering_nodes,  :only => [:index, :show]
      resources :service_offerings,       :only => [:index, :show] do
        post "applied_inventories", :to => "service_offerings#applied_inventories"
        post "order", :to => "service_offerings#order"
        resources :service_instances,      :only => [:index]
        resources :service_offering_nodes, :only => [:index]
        resources :service_plans,          :only => [:index]
        resources :tags,                   :only => [:index]
      end
      resources :service_plans, :only => [:index, :show] do
        post "order", :to => "service_plans#order"
        resources :service_instances, :only => [:index]
      end
      resources :sources,                  :only => [:index, :show] do
        resources :service_instances,      :only => [:index]
        resources :service_instance_nodes, :only => [:index]
        resources :service_inventories,    :only => [:index]
        resources :service_offerings,      :only => [:index]
        resources :service_offering_nodes, :only => [:index]
        resources :service_plans,          :only => [:index]
      end
      resources :tags, :only => [:index, :show] do
        resources :service_inventories, :only => [:index]
        resources :service_offerings,   :only => [:index]
      end
      resources :tasks, :only => [:index, :show, :update]
    end

    namespace :cfme do
      resources :manifest, :only => [:show], :constraints => {:id => /[\d\.]+/}
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
