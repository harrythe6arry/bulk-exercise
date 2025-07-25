class BulkCharge < ApplicationRecord
  has_one_attached :csv_file
  has_many :charge_results, dependent: :destroy

  enum status: {
    pending: 'pending',
    in_progress: 'in_progress',
    completed: 'completed',
    failed: 'failed'
  }

  validates :csv_file, presence: true, content_type: 'text/csv'
end