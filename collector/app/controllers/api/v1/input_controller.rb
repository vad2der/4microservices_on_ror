module Api
  module V1
    class InputController < ApplicationController
      before_action :restrict_access

      def create
        begin
          # check if such enrty is not presented in the DB
          if Entry.where(input: params.to_json).all.size < 1
            entry = Entry.create!(input: params.to_json)
            start = Time.now
            
            # set the threshold - how many second do we wait while the delivery/response process goes to/from the Parser microservice
            threshold_seconds = Rails.env == "production" ? ENV["THRESHOLD_SECONDS"].to_i : 5
            
            # loop it
            begin
              delivered = entry.delivered_to_parser ? entry.delivered_to_parser : false
            end while (entry.delivery_tries < 0 || Time.now - start < threshold_seconds)
            
            render json: {message: 'data recieved and saved', id: entry.id, delivered: entry.delivered_to_parser, delivery_tries: entry.delivery_tries}, status: :created
          else
            # check if such entry already exists and report it without creating the DB entry
            entry = Entry.where(input: params.to_json).first
            if (entry.delivered_to_parser == false || entry.delivered_to_parser.nil?)
              entry.send_to_parser()
            end
            render json: {message: 'data is already presented in the db', id: entry.id, delivered: entry.delivered_to_parser, delivery_tries: entry.delivery_tries}, status: :created
          end
        rescue => err
          # if something went wrong
          # log it
          render json: {
            status: 'warning, check your server logs.',
            details: err.inspect
          }, status: :internal_server_error
        end
      end

      private
      def input_params
        # do we want any params to be whitelisted?
        # params.fetch([], :tokens, :format, :session, :auth_headers)
      end
      
      def restrict_access
        # check api-key in Headers
        header_api_key = request.headers['api-key']
        @api_key = AppApiKey.where(api_key: header_api_key).first if header_api_key
        unless @api_key
          render json: { error: 'Unauthorized' }, status: :unauthorized
        end
      end

    end
  end
end
