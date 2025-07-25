class BulkCharge < ApplicationRecord
  has_one_attached :csv_file
  has_many :charge_results, dependent: :destroy

  enum :status, { pending: 0, in_progress: 1, completed: 2, failed: 3 }

  validates :csv_file, presence: true
end