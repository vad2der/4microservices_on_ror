module Api
  module V1
    class CheckNonDeliveredController < ApplicationController
      before_action :restrict_access

      def index
        EntriesCheck.deliver_entries()
        render json: {message: "undelivered entries processed"}, status: :ok
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