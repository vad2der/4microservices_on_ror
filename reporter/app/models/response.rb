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
end
