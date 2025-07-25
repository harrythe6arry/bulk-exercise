class CsvController < ApplicationController
  def new
    @csv_upload = CsvUpload.new
  end

  def create
    @csv_upload = CsvUpload.new(csv_upload_params)

    if @csv_upload.save
      redirect_to @csv_upload, notice: "CSV file was successfully uploaded."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @csv_upload = CsvUpload.find(params[:id])
  end

  private

  # Use strong parameters to permit the file attribute
  def csv_upload_params
    params.require(:csv_upload).permit(:csv_file)
  end
end
