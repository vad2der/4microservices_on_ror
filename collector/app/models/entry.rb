require 'securerandom'
require 'httparty'

class Entry
  include Mongoid::Document
  field :id, type: String
  field :input, type: String
  field :delivered_to_parser, type: Mongoid::Boolean, default: false
  field :delivery_tries, type: Integer, default: 0

  before_create :generate_unique_uid
  after_create :send_to_parser

  def generate_unique_uid
    self.id = SecureRandom.hex(10)
    generate_unique_uid() if self.class.where(id: self.id).all.size > 0
  end

  def send_to_parser
    begin
      # form the payload of what we are going to send to the Parser microservice
      body = {:input => self.input,
        :id => self.id
      }.to_json

      # getting api_key to be able to address to Parser microservice
      api_key = AppApiKey.first.api_key
      
      # getting the Parser microservice URL dependiong on environment
      parser_url = Rails.env == "production" ? ENV["PARSER_URL"] : "http://0.0.0.0:3001"
      parser_url = parser_url + '/api/v1/parse'
      # actual HTTP call (POST / include api-key in the )
      response = HTTParty.post(parser_url,
        :body => body,
        :headers => {'Content-Type' => 'application/json',
        'api-key' => api_key}
      )

      # if call returned status OK, mark that it was successful
      if response && response.code == 201
        mark_as_delivered()
      end

    rescue => err
      # log it
      puts err.inspect
      puts 'Failed set_to_parser'
    ensure
      # let's count how many times we tried to send the data to the Parser
      if self.delivery_tries.is_a?(Integer)
        delivery_tries = self.delivery_tries + 1        
      else
        delivery_tries = 1
      end
      self.update(delivery_tries: delivery_tries)
    end
  end

  def mark_as_delivered
    self.update(delivered_to_parser: true)
  end
end
