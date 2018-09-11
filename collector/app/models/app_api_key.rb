class AppApiKey
  include Mongoid::Document
  field :api_key, type: String

  before_create :generate_api_key
  
  private
    def generate_api_key
      self.api_key = SecureRandom.hex(12)
      generate_api_key() if self.class.where(api_key: self.api_key).all.size > 0
    end
end
