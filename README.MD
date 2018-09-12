# Microservices on RoR
## 1. Requiremets

  - Ruby v2.4+
  - Ruby on Rails v 5.1+
  - MongoDB
  
## 2. Running instructions on localhost
  - clone the repo
  - go into each microservice folder (collector, parser, reporter), run `bundle` command to install necessary modules
  - have MongoDB running
  - go into `collector` environment and create *AppApiKey*, use it in calls to `collector` and `reporter` afterwards:
  ```sh
$ rails c
$ AppApiKey.create!()
```
  - start `collector` on port 3000:
```sh
$ rails s -p 3000
```
  - start `parser` on port 3000:
```sh
$ rails s -p 3001
```
  - start `reporter` on port 3000:
```sh
$ rails s -p 3002
```

## 3. Note

> `parser` includes `persister`. Reasoning behind this - requirement to the microservices chain to be robust against situations when 1 or more items in the chain are off. To provide it - we need to save inputs right away. So, if `parser` saves inputs, then why not to save them in the parsed format right away. In case parser does not save anything `persister` have nothing to ask from `parser` on start/restart (another way to restart process for the whole chain every time)

> for simplicity all 3 apps uses same DB.

## 4. Idea explanation

> `collector` saves any payload it gets. Assigns an **entry_id** to it, tryes delivering to `parser` during set number of seconds. On start it checks if any enrties were not delivered and tryes again. Every delivery attempt is counted.

> `parser` gets a payload from `collector` including **entry_id**, saves them as properly formatted **Invoice** or **Response** plus **entry_id**. On start it asks `collector` to check if there are undelivered entries.

> `reporter` responds with relevant DB documents by **entry_id** or by **originalDocumentNumber**

# 5. Collector
One can set following environment variables:
- ENV["THRESHOLD_SECONDS"] - how many seconds `collector` waits on **entry** delivery (default 5 sec)
- ENV["PARSER_URL"] - url of the next microservice in the chain. (default in development environment localhost:3001)

## 5.1. Entities/Models:
### 5.1.1. Entry
```sh
class Entry
  field :id, type: String
  field :input, type: String
  field :delivered_to_parser, type: Mongoid::Boolean, default: false
  field :delivery_tries, type: Integer, default: 0
end
```
## 5.2. APIs:
- provide Headers: {api-key: AppAkyKey} (see section 2, step 4)
### 5.2.1. api/v1/health_check
Simple check of server health and if it has DB connection
- method GET
- success response:
```sh
{   "status": "server works",
    "db_collection": "entries",
    "time_took": 0.00007919,
    "time_units": "ms"}, 200
```
### 5.2.2. api/v1/input
Saves the input as **Entry** into MongoDB 
- method POST
- payload:
```sh
[  { "responseNumber": "1264",
    "originalInvoiceNumber": "879755",
    "status": "Rejected",
    "date": "2016-10-14",
    "amount": "2481.86",
    "currency": "USD"  },
...
  {  "invoiceNumber": "16547",
    "date": "2016-05-01",
    "amount": "554.78",
    "currency": "USD"  },
 ...]
```
- success response:
```sh
{   "message": "data recieved and saved",
    "id": "265b1753cafa4c882741",
    "delivered": true,
    "delivery_tries": 1}, 201
```
### 5.2.3. api/v1/check_non_delivered
Used as a trigger for anyther deliverty try of **Entry** to `parser`. Called from `parser` on it's start
- method GET
- success response:
```sh
{"message": "undelivered entries processed"}, 200
```
## 5.3. Features
- counts delivery tries
- marks entry on succesfull delivery
- tries delivering non-delivered entries to `parser` on start
- tries delivering non-delivered entries to `parser` on HTTP call

# 6. Parser
One can set following environment variables:
- ENV["COLLECTOR_URL"] - url of the pprevious microservice in the chain. (default in development environment localhost:3000)

## 6.1. Entities/Models:
### 6.1.1. Invoice
```sh
class Invoice
  field :documentType, type: String, default: "Invoice"
  field :documentNumber, type: String
  field :date, type: Integer # converted to rational and then to integer
  field :amount, type: Float # rounded to 2 decimal places on creation
  field :currency, type: String
  field :entry_id, type: String
end
```
### 6.1.2. Response
```sh
class Response
  include Mongoid::Document
  field :documentType, type: String, default: "Response"
  field :documentNumber, type: String
  field :originalDocumentNumber, type: String
  field :status, type: String
  field :date, type: Integer # converted to rational and then to integer
  field :amount, type: Float # rounded to 2 decimal places on creation
  field :currency, type: String
  field :entry_id, type: String
end
```
## 6.2. APIs:
- provide Headers: {api-key: AppAkyKey} (see section 2, step 4)
### 6.2.1. api/v1/health_check
Simple check of server health and if it has DB connection
- method GET
- success response:
```sh
{   "status": "server works",
    "db_collection": ["invoices", "responses"],
    "time_took": 0.00007919,
    "time_units": "ms"}, 200
```
### 6.2.2. api/v1/parse
Gets payload from `collector` in original form, parses it into **Invoices** or/and ***Responses** and save them
- method POST
- payload:
```sh
[  { "responseNumber": "1264",
    "originalInvoiceNumber": "879755",
    "status": "Rejected",
    "date": "2016-10-14",
    "amount": "2481.86",
    "currency": "USD"  },
...
  {  "invoiceNumber": "16547",
    "date": "2016-05-01",
    "amount": "554.78",
    "currency": "USD"  },
 ...]
```
- success response:
```sh
{"message": "Payload received"}, 201
```
## 6.3. Features
- On start calls `collector` so that it checked for non-delivered entries and try delivering them
- Parses payload and saves then as **Invoice** and/or **Response** (see also section 3 and 4)

# 7. Reporter
## 7.1. Entities/Models:
### 7.1.1. Entry
see section 5.1.1.
### 7.1.2. Invoice
see section 6.1.1.
### 7.1.3. Response
see section 6.1.2.

## 7.2. APIs:
- provide Headers: {api-key: AppAkyKey} (see section 2, step 4)
### 7.2.1. api/v1/health_check
Simple check of server health and if it has DB connection
- method GET
- success response:
```sh
{   "status": "server works",
    "db_collection": ["entries", "invoices", "responses"],
    "time_took": 0.00007919,
    "time_units": "ms"}, 200
```
### 7.2.2. api/v1/report_by_document/documentNumber
Returning **invoices** and **responses** by `invoice[:documentNumber]` and/or `response[:originalDocumentNumber]`.
Responses without invoices are returned as well.

- method GET
- success response:
```sh
[    {  "original": {
            "documentType": "Invoice",
            "documentNumber": "44977",
            "date": 1468908000000,
            "amount": 915.7,
            "currency": "CAD"
        }, "responses": [
            {    "documentType": "Response",
                "documentNumber": "56149",
                "originalDocumentNumber": "44977",
                "status": "Paid",
                "date": 1469253600000,
                "amount": 915.7,
                "currency": "CAD"            }
        ]
    }], 200
```
### 7.2.2. api/v1/report_by_document/entry_id
Returning **invoices** and **responses** by entry_id (see section 5.2.2. __id__ field in seccesfull response)
Return is grupped by `invoice[:documentNumber]` and ordered by invoice date. Note that Responses without invoices goes to the end.

- method GET
- success response:
```sh
[    {  "original": {
            "documentType": "Invoice",
            "documentNumber": "16547",
            "date": 1462082400000,
            "amount": 554.78,
            "currency": "USD"
        }, "responses": []
    }, {
        "original": {
            "documentType": "Invoice",
            "documentNumber": "44977",
            "date": 1468908000000,
            "amount": 915.7,
            "currency": "CAD"
        }, "responses": [
            {    "documentType": "Response",
                "documentNumber": "56149",
                "originalDocumentNumber": "44977",
                "status": "Paid",
                "date": 1469253600000,
                "amount": 915.7,
                "currency": "CAD"            }
        ]
    },
    ...
    {   "original": {},
        "responses": {
            "documentType": "Response",
            "documentNumber": "45746",
            "originalDocumentNumber": "4497",
            "status": "Approved",
            "date": 1448953200000,
            "amount": 45.57,
            "currency": "USD"
        }
    }], 200
```
