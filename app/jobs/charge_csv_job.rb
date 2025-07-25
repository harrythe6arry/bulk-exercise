class ChargeCsvJob
  include Sidekiq::Job
  require 'csv'

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
  p "Processing row #{row_number}: #{row_data.inspect}"
  p "the parameters of the row are #{row_data.to_h}"

  skey = row_data['skey']
  pkey1 = row_data['pkey'] 
  card_name = row_data['card_name']
  charge_amount = row_data['charge_amount']
  charge_currency = row_data['charge_currency']

  p "The extraction are skey: #{skey}, pkey: #{pkey1}, card_name: #{card_name}, charge_amount: #{charge_amount}, charge_currency: #{charge_currency}"
end
end