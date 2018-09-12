class Entry
  include Mongoid::Document

  field :id, type: String
  field :input, type: String
  field :delivered_to_parser, type: Mongoid::Boolean, default: false
  field :delivery_tries, type: Integer, default: 0
  
end
