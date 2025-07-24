class PagesController < ApplicationController
    http_basic_authenticate_with name: "kevin", password: "12345", only: :info
    include Sidekiq::Worker

  def index 
  end

  def info
    @message = "This is a simple user authentication system using HTTP Basic Authentication."
  end

  def upload_csv
    uploaded_file = params[:csv_file]
    if uploaded_file.present?
      file_path = Rails.root.join('tmp', uploaded_file.original_filename)
      File.open(file_path, 'wb') { |f| f.write(uploaded_file.read) }
      CsvImportWorker.perform_async(file_path.to_s)
      redirect_to info_path, notice: "CSV upload started. Processing in background."
    else
      redirect_to info_path, alert: "Please select a CSV file to upload."
    end
  end

end
