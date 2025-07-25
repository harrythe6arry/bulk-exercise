class ChargeCsvJob
  include Sidekiq::Job
  require 'csv'

  def perform(bulk_charge_id)
    bulk_charge = BulkCharge.find(bulk_charge_id)
    return unless bulk_charge
    bulk_charge.update!(status: :in_progress)
    csv_text = bulk_charge.csv_file.download
    CSV.parse(csv_text, headers: true).each.with_index(1) do |row, index|
      process_row(bulk_charge, row, index)
    end
    bulk_charge.update!(status: :completed)
  rescue StandardError => e
    bulk_charge&.update!(status: :failed)
  end

  private

  def process_row(bulk_charge, row_data, row_number)
    p" Processing row #{row_number}: #{row_data.inspect}"
  end
end