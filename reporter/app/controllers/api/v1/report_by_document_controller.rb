module Api
  module V1
    class ReportByDocumentController < ApplicationController
      before_action :restrict_access
      before_action :set_document, only: [:show]
      
      def show
        responses = []
        @responses.order_by(date: :desc).each {|r| 
          responses << {
            :documentType => r[:documentType],
            :documentNumber => r[:documentNumber],
            :originalDocumentNumber => r[:originalDocumentNumber],
            :status => r[:status],
            :date => r[:date],
            :amount => r[:amount],
            :currency => r[:currency]
          }
        }
        resp = [
          {
            :original => {
              :documentType => @invoice[:documentType],
              :documentNumber => @invoice[:documentNumber],
              :date => @invoice[:date],
              :amount => @invoice[:amount],
              :currency => @invoice[:currency]
            },
            :responses => responses
          }        
        ]
        render json: resp, satus: :ok
      end

      private
      def restrict_access
        header_api_key = request.headers['api-key']
        @api_key = AppApiKey.where(api_key: header_api_key).first if header_api_key
        unless @api_key
          render json: { error: 'Unauthorized' }, status: :unauthorized
        end
      end

      def set_document
        @invoice = Invoice.where(documentNumber: params[:id]).first
        @responses = Response.where(originalDocumentNumber: params[:id]).all
        if @invoice.nil? && @response.nil?
          render json: { error: 'No such Documents found'}, status: :bad_request
        end
      end

    end
  end
end
