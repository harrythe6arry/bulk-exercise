class CsvImportWorker
  include Sidekiq::Worker

  def perform(file_path)
    require 'csv'
    CSV.foreach(file_path, headers: true) do |row|
      # Process each row (e.g., create a record)
      # Example: User.create!(row.to_hash)
    end
    File.delete(file_path) if File.exist?(file_path)
  end
end