class AppApiKey
  include Mongoid::Document
  field :api_key, type: String
end
