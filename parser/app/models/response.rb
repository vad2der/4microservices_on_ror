class Response
  include Mongoid::Document
  field :documentType, type: String, default: "Response"
  field :documentNumber, type: String
  field :originalDocumentNumber, type: String
  field :status, type: String
  field :date, type: Integer
  field :amount, type: Float
  field :currency, type: String
  field :entry_id, type: String
  # field :delivered_to_persister, type: Mongoid::Boolean, default: false
  # field :delivery_tries, type: Integer, default: 0
  
  # after_create :send_to_persister

  # def send_to_persister
  #   begin
  #     # form the payload of what we are going to send to the Persister microservice
  #     body = {:documentType => self.documentType,
  #       :documentNumber => self.documentNumber,
  #       :originalDocumentNumber => self.originalDocumentNumber,
  #       :status => self.status,
  #       :date => self.date,
  #       :amount => self.amount,
  #       :currency => self.currency
  #     }.to_json

  #     puts body
  #     # getting api_key to be able to address to Persister microservice
  #     api_key = AppApiKey.first.api_key
      
  #     # getting the Persister microservice URL dependiong on environment
  #     persister_url = Rails.env == "production" ? ENV["PERSISTER_URL"] : "http://0.0.0.0:3002"
  #     persister_url = persister_url + '/api/v1/persister'
  #     # actual HTTP call (POST / include api-key in the )
  #     response = HTTParty.post(persister_url,
  #       :body => body,
  #       :headers => {'Content-Type' => 'application/json',
  #       'api-key' => api_key}
  #     )

  #     # if call returned status OK, mark that it was successful
  #     if response && response.code == 201
  #       mark_as_delivered()
  #     end

  #   rescue => err
  #     # log it
  #     puts err.inspect
  #     puts 'Failed set_to_persister'
  #   ensure
  #     # let's count how many times we tried to send the data to the Persister
  #     if self.delivery_tries.is_a?(Integer)
  #       delivery_tries = self.delivery_tries + 1        
  #     else
  #       delivery_tries = 1
  #     end
  #     self.update(delivery_tries: delivery_tries)
  #   end
  # end

  # def mark_as_delivered
  #   self.update(delivered_to_persister: true)
  # end
end
