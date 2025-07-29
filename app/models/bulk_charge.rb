class BulkCharge < ApplicationRecord
  has_one_attached :csv_file
  has_many :charge_results, dependent: :destroy

  enum :status, { pending: 0, in_progress: 1, completed: 2, failed: 3 }

  validate :csv_file_presence

  private

  def csv_file_presence
    errors.add(:csv_file, "can't be blank") unless csv_file.attached?
  end
end