class Invoice
  include Mongoid::Document

  field :documentType, type: String, default: "Invoice"
  field :documentNumber, type: String
  field :date, type: Integer
  field :amount, type: Float
  field :currency, type: String
  field :entry_id, type: String
  
end
