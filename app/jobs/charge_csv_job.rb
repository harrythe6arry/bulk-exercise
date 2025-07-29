class ChargeCsvJob
  include Sidekiq::Job
  require 'csv'
  require 'faraday'
  require 'json'
  require 'base64'

  def perform(bulk_charge_id)
    p "Starting ChargeCsvJob for BulkCharge ID: #{bulk_charge_id}"
    bulk_charge = BulkCharge.find(bulk_charge_id)
    return unless bulk_charge
    bulk_charge.update!(status: :in_progress)
    csv_text = bulk_charge.csv_file.download
    p "CSV file downloaded for BulkCharge ID: #{bulk_charge_id}, content length: #{csv_text.length} characters"
    CSV.parse(csv_text, headers: true).each.with_index(1) do |row, index|
      process_row(bulk_charge, row, index)
    end
    bulk_charge.update!(status: :completed)
  rescue StandardError => e
    bulk_charge&.update!(status: :failed)
  end

  private
  
  def process_row(bulk_charge, row_data, row_number)
    p "Processing row #{row_number} for BulkCharge ID: #{bulk_charge.id}"
    pkey = Rails.application.credentials.omise[:public_key]
    card_name = "JOHN DOE"
    card_city = "Bangkok"
    card_postal_code = "10320"
    card_number = "4242424242424242"
    card_security_code = "123"
    card_expiration_month = "3"
    card_expiration_year = "2030"

    begin
    conn = Faraday.new(url: 'https://vault.staging-omise.co')
    response = conn.post('/tokens') do |req|
      req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
      req.headers['Authorization'] = "Basic #{Base64.strict_encode64("#{pkey}:")}"
      req.body = URI.encode_www_form(
        "card[name]" => card_name,
        "card[city]" => card_city,
        "card[postal_code]" => card_postal_code,
        "card[number]" => card_number,
        "card[security_code]" => card_security_code,
        "card[expiration_month]" => card_expiration_month,
        "card[expiration_year]" => card_expiration_year
      )
      p "Request body: #{req.body}"
    end
    p "Vault API response status: #{response.status}"
    p "Vault API response body: #{response.body.inspect}"
    p "Vault API response headers: #{response.headers.inspect}"
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
    Omise.api_key = "skey_64hsrbe7jgdvnwd5aqm"
    p "Omise SECRET API key set to: #{Omise.api_key}"

    conn = Faraday.new(url: 'https://api.staging-omise.co')
    response = conn.post('/charges') do |req|
    req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
    req.headers['Authorization'] = "Basic #{Base64.strict_encode64("#{Omise.api_key}:")}"
    req.body = URI.encode_www_form(
      "description" => "Charge for order #{bulk_charge.id}",
      "amount" => 200000,
      "currency" => 'THB',
      "return_uri" => "http://www.example.com/orders/#{bulk_charge.id}/complete",
      "card" => source_token
    )
      p "Request body: #{req.body}"
      end
    end
  end
end