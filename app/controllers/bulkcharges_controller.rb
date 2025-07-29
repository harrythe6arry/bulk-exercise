class BulkchargesController < ApplicationController
  def index
    @bulk_charges = BulkCharge.all.order(created_at: :desc)
  end

  def new
    @bulk_charge = BulkCharge.new
  end
  def create

  @bulk_charge = BulkCharge.new(bulk_charge_params)
  @bulk_charge.status = :pending

  if @bulk_charge.save
    row_count = @bulk_charge.csv_file.blob.open { |file| file.each_line.count }
    p "the row count is #{row_count}"
    if row_count > 500
      @bulk_charge.errors.add(:csv_file, "cannot have more than 500 rows")
      @bulk_charge.destroy
      return render :new, status: :unprocessable_entity
    end
    p "the job is being enqueued"
    ChargeCsvJob.perform_async(@bulk_charge.id)
    p" the job is enqueued with ID #{@bulk_charge.id}"
    flash[:notice] = "Bulk charge is being processed. You can check the status later"
    redirect_to bulkcharge_path(@bulk_charge), notice: 'Bulk charge was successfully created.'
  else
    render :new, status: :unprocessable_entity
  end
  end

  def show
    @bulk_charge = BulkCharge.find(params[:id])
    @charge_results = @bulk_charge.charge_results.order(:row_number)
  end
  def csv_preview
    @bulk_charge = BulkCharge.find(params[:id])
    @csv_rows = []
    if @bulk_charge.csv_file.attached?
      @bulk_charge.csv_file.blob.open do |file|
        @csv_rows = CSV.parse(file.read, headers: true)
      end
    end
  end
  
  private
  
  def bulk_charge_params
    params.require(:bulk_charge).permit(:csv_file)
  end
end