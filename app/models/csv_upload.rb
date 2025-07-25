class CsvUpload < ApplicationRecord
  has_one_attached :csv_file
  validates :csv_file, presence: true, content_type: 'text/csv'
end
