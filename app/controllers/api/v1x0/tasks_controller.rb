module Api
  module V1x0
    class TasksController < ApplicationController
      include Mixins::IndexMixin
      include Mixins::ShowMixin

      def update
        model.update(params.require(:id), params_for_update)

        head :no_content
      end

      # insights-api-common validate_primary_collection_id method doesn't handle
      # the case of sources and tasks have different primary ID pattern.
      # TODO: remove this after https://github.com/RedHatInsights/insights-api-common-rails/pull/224 is merged
      private_class_method def self.id_regexp(primary_collection_name)
        @id_regexp = if primary_collection_name == 'sources'
                       /^\d+$/
                     else
                       /[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12}/
                     end
      end

      private

      def params_for_update
        permitted = api_doc_definition.all_attributes - api_doc_definition.read_only_attributes

        if body_params['result'].present?
          permitted.delete('result')
          permitted << {'result'=>{}}
        end

        if body_params['input'].present?
          permitted.delete('input')
          permitted << {'input'=>{}}
        end

        if body_params['output'].present?
          permitted.delete('output')
          permitted << {'output'=>{}}
        end

        permitted << 'source_id'
        body_params.permit(*permitted)
      end
    end
  end
end
