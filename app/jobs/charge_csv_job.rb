class ChargeCsvJob
  include Sidekiq::Job
  require 'csv'
  require 'faraday'
  require 'json'
  require 'base64'
  require "omise"

  def perform(bulk_charge_id)
    p "Starting ChargeCsvJob for BulkCharge ID: #{bulk_charge_id}"
    bulk_charge = BulkCharge.find(bulk_charge_id)
    return unless bulk_charge
    bulk_charge.update!(status: :in_progress)
    csv_text = bulk_charge.csv_file.download
    # p "CSV file downloaded for BulkCharge ID: #{bulk_charge_id}, content length: #{csv_text.length} characters"
    CSV.parse(csv_text, headers: true).each.with_index(1) do |row, index|
      process_row(bulk_charge, row, index)
    end
    bulk_charge.update!(status: :completed)
  rescue StandardError => e
    bulk_charge&.update!(status: :failed)
  end

  private
  
  def process_row(bulk_charge, row_data, row_number)
    # p "Processing row #{row_number} for BulkCharge ID: #{bulk_charge.id}"
    # pkey = Rails.application.credentials.omise[:public_key]
    card_pkey = row_data["pkey"] || Rails.application.credentials.omise[:public_key]
    card_skey = row_data['skey'] || Rails.application.credentials.omise[:secret_key]
    card_name = row_data['card_name'] || "Default Name"
    card_city = row_data['card_city'] || "Default City"
    card_postal_code = row_data['postal_code'] || "00000"
    card_number =  row_data['card_number'] || "4242424242424242" 
    card_security_code = row_data['security_code'] || "123" 
    card_expiration_month = row_data['expiration_month'] || "12" 
    card_expiration_year = row_data['expiration_year'] || "2025"
    card_charge_amount = row_data['charge_amount'] || "200000" 
    card_charge_currency = row_data['charge_currency'] || "THB"
    p "Row #{row_number} data: #{row_data.inspect}"
    # p "the card charge amount is #{card_charge_amount}"
    # p "the card charge currency is #{card_charge_currency}"
    # p "the public key is #{card_pkey}"
    # p "the secret key is #{card_skey}"
    vault_url = ENV.fetch("OMISE_VAULT_URL")
    api_url   = ENV.fetch("OMISE_API_URL")
    p "Vault URL: #{vault_url}"
    p "API URL: #{api_url}"

    begin
    conn = Faraday.new(url: vault_url)
    response = conn.post('/tokens') do |req|
      req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
      req.headers['Authorization'] = "Basic #{Base64.strict_encode64("#{card_pkey}:")}"
      req.body = URI.encode_www_form(
        "card[name]" => card_name,
        "card[city]" => card_city,
        "card[postal_code]" => card_postal_code,
        "card[number]" => card_number,
        "card[security_code]" => card_security_code,
        "card[expiration_month]" => card_expiration_month,
        "card[expiration_year]" => card_expiration_year
      )
      # p "Request body: #{req.body}"
    end
    # p "Vault API response status: #{response.status}"
    # p "Vault API response body: #{response.body.inspect}"
    # p "Vault API response headers: #{response.headers.inspect}"
    rescue => e
    p "Exception during Vault API call: #{e.class} - #{e.message}"
    p e.backtrace
    return

    end
    p "the req.body is #{response.body}"
    token_response = JSON.parse(response.body)
    p "Token response: #{token_response.inspect}"
    source_token = token_response['id']
    p "Source token created: #{source_token}"
    p "Token response: #{token_response}"

    begin
    Omise.api_key = card_skey
    Omise.api_version = "2019-05-29"
    # p "Omise SECRET API key set to: #{Omise.api_key}"

    conn = Faraday.new(url: api_url)
    response = conn.post('/charges') do |req|
    req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
    req.headers['Authorization'] = "Basic #{Base64.strict_encode64("#{Omise.api_key}:")}"
    req.body = URI.encode_www_form(
      "description" => "Charge for order #{bulk_charge.id}",
      "amount" => card_charge_amount.to_i * 100,
      "currency" => card_charge_currency,
      "return_uri" => "http://www.example.com/orders/#{bulk_charge.id}/complete",
      "card" => source_token
    )
      # p "Request body: #{req.body}"      
    end
  end
    rescue => e
      p "Exception during Omise API call: #{e.class} - #{e.message}"
      p e.backtrace
      return
end
end
