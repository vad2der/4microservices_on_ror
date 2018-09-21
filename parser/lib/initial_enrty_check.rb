require './config/boot'
require './config/environment'
require 'clockwork'
require 'httparty'

include Clockwork

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

handler do |job|
    puts "Running #{job}"
end

every(3.minutes, 'run http call to check non delivered') {
    Checker.undelivered_from_collector()
}