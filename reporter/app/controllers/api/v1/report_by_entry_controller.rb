module Api
  module V1
    class ReportByEntryController < ApplicationController
      before_action :restrict_access
      before_action :set_entry, only: [:show]

      def show
        resp = []
        invoce_document_numbers = []
        @invoices.each {|inv|
          invoce_document_numbers << inv[:documentNumber]
          responses = []
        
          @responses.where(originalDocumentNumber: inv[:documentNumber]).order_by(date: :desc).each {|r| 
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

          item = {
            :original => {
              :documentType => inv[:documentType],
              :documentNumber => inv[:documentNumber],
              :date => inv[:date],
              :amount => inv[:amount],
              :currency => inv[:currency]
            },
            :responses => responses
          }
          resp << item
        }

        puts invoce_document_numbers
        if invoce_document_numbers.size > 0
          @responses.not_in(:originalDocumentNumber => invoce_document_numbers).all.order_by(date: :desc).each {|r|
            item = {
              :original => {},
              :responses => {
                :documentType => r[:documentType],
                :documentNumber => r[:documentNumber],
                :originalDocumentNumber => r[:originalDocumentNumber],
                :status => r[:status],
                :date => r[:date],
                :amount => r[:amount],
                :currency => r[:currency]
              }
            }
            resp << item
          }
        end
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

      def set_entry
        @invoices = Invoice.where(entry_id: params[:id]).all
        @responses = Response.where(entry_id: params[:id]).all
        if @invoices.size == 0 && @responses == 0
          render json: { error: 'No such Entry found'}, status: :bad_request
        end
      end

    end
  end
end
