module Api
  module V1
    class ParseController < ApplicationController
      before_action :restrict_access
      before_action :set_params, only: [:create]

      def create
        puts @payload
        @payload.each {|p|
          if p[:originalInvoiceNumber] # we may make type recognition by a number of params
            Response.where(
              :documentNumber => p[:responseNumber],
              :originalDocumentNumber => p[:originalInvoiceNumber],
              :status => p[:status],
              :date => (p[:date].to_date.to_time.to_r * 1000).to_i,
              :amount => p[:amount].to_f.round(2),
              :currency => p[:currency],
              :entry_id => @entry_id
            ).first_or_create
            puts p
          elsif p[:invoiceNumber]
            Invoice.where(
              :documentNumber => p[:invoiceNumber],
              :date => (p[:date].to_date.to_time.to_r * 1000).to_i,
              :amount => p[:amount].to_f.round(2),
              :currency => p[:currency],
              :entry_id => @entry_id
            ).first_or_create
          end
        }
        render json: {message: "Payload received"}, status: :created
      end

      private
      def restrict_access
        header_api_key = request.headers['api-key']
        @api_key = AppApiKey.where(api_key: header_api_key).first if header_api_key
        unless @api_key
          render json: { error: 'Unauthorized' }, status: :unauthorized
        end
      end

      def set_params
        @entry_id = params[:id]
        @payload = eval(params[:input])
        if @payload[:_json]
          @payload = @payload[:_json]
        end
      end

    end
  end
end
