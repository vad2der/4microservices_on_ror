module Api
  module V1
    class HealthCheckController < ApplicationController
      before_action :restrict_access

      def index
        begin
          start = Time.now
          db_response = Entry.collection_name        
          duration = Time.now - start        
          render json: {
            status: 'server works',
            db_collection: db_response,
            time_took: duration,
            time_units: 'ms'}, status: :ok
        rescue => err
          # log it
          render json: {
            status: 'warning, check your server logs.',
            details: err.inspect
          }, status: :internal_server_error
        end
      end

      private
      def restrict_access
        header_api_key = request.headers['api-key']
        @api_key = AppApiKey.where(api_key: header_api_key).first if header_api_key
        unless @api_key
          render json: { error: 'Unauthorized' }, status: :unauthorized
        end
      end

    end
  end
end
