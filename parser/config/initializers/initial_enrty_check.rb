#!/usr/bin/env ruby
# class ResponsesCheck
#     def self.deliver_responses
#         undelivered = Response.where(delivered_to_persister: false).all
#         undelivered.each {|ud|
#             ud.send_to_parser()
#         }
#         undelivered = Response.where(delivered_to_persister: nil).all
#         undelivered.each {|ud|
#             ud.send_to_parser()
#         }
#     end
# end
# class InvoicesCheck
#     def self.deliver_invoices
#         undelivered = Invoice.where(delivered_to_persister: false).all
#         undelivered.each {|ud|
#             ud.send_to_parser()
#         }
#         undelivered = Invoice.where(delivered_to_persister: nil).all
#         undelivered.each {|ud|
#             ud.send_to_parser()
#         }
#     end
# end
class Checker
    def self.undelivered_from_collector

        # getting api_key to be able to address to Parser microservice
        api_key = AppApiKey.first.api_key
        collector_url = Rails.env == "production" ? ENV["COLLECTOR_URL"] : "http://0.0.0.0:3000"
        collector_url = collector_url + '/api/v1/check_non_delivered'
        HTTParty.get(collector_url,            
            :headers => {'Content-Type' => 'application/json',
            'api-key' => api_key}
          )
    end
end