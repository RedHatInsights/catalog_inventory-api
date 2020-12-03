module Api
  module Cfme
    class ManifestController < ApplicationController
      def show
        version = params.permit(:id)[:id]
        raise ActionController::RoutingError.new('Not Found') unless version =~ /\A[\d\.]+\Z/

        file = CatalogInventory::Api::CfmeManifest.find(version)
        raise ActionController::RoutingError.new('Not Found') if file.nil?

        render :json => file.read
      end
    end
  end
end
