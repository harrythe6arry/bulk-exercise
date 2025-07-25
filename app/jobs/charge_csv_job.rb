class ChargeCsvJob
  include Sidekiq::Job
  require 'csv'
  require 'faraday'
  require 'json'

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

    # the vault will be configured later on to switch
    conn = Faraday.new(url: 'https://vault.staging-omise.co')
    p "Connecting to Omise Vault API with primary key: #{pkey}"
    response = conn.post('/tokens') do |req|
      req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
      req.basic_auth(pkey, Rails.credentials.omise[:public_key])
      req.body = URI.encode_www_form(
        "card[name]" => card_name,
        "card[city]" => card_city,
        "card[postal_code]" => card_postal_code,
        "card[number]" => card_number,
        "card[security_code]" => card_security_code,
        "card[expiration_month]" => card_expiration_month,
        "card[expiration_year]" => card_expiration_year
      )
    end
    p "Vault API response status: #{response.status}"
    if response.status != 200
      p "Vault API error: #{response.body}"
      return
    end
    p "the req.body is #{response.body}"
    token_response = JSON.parse(response.body)
    p "Token response: #{token_response.inspect}"
    source_token = token_response['id']
    p "Source token created: #{source_token}"
    p "Token response: #{token_response}"
    Omise.api_key = Rails.application.credentials.omise[:secret_key]
    p "Omise SECRET API key set to: #{Omise.api_key}"
    charge = Omise::Charge.create(
      source: source_token,
      amount: row_data['charge_amount'],
      currency: row_data['charge_currency'] || 'thb',
      return_uri: 'https://yourwebsite.com/success'
    )
    p "Omise charge response: #{charge.inspect}"

  end
end