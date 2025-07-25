class BulkchargesController < ApplicationController
  def new
    @bulk_charge = BulkCharge.new
  end

  def create
    @bulk_charge = BulkCharge.new(bulk_charge_params)
    @bulk_charge.status = :pending 

    unless @bulk_charge.csv_file.attached?
      @bulk_charge.errors.add(:csv_file, "must be present")
      return render :new, status: :unprocessable_entity
    end

    row_count = @bulk_charge.csv_file.blob.open { |file| file.each_line.count}
    if row_count > 500
      @bulk_charge.errors.add(:csv_file, "cannot have more than 500 rows")
      return render :new, status: :unprocessable_entity
    end
  def show
    @bulk_charge = BulkCharge.find(params[:id])
    @charge_results = @bulk_charge.charge_results.order(:row_number)
  end

  private  
  def bulk_charge_params
    params.require(:bulk_charge).permit(:csv_file)
  end
end
end
