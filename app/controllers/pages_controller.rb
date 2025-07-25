class PagesController < ApplicationController
    http_basic_authenticate_with name: "harry", password: "12345", only: :info
    include Sidekiq::Worker

  def index
  end

  def info
    @message = "This is a simple user authentication system using HTTP Basic Authentication."
  end

  def upload_csv
  uploaded_file = params[:csv_file]
  p "the uploaded file is: #{uploaded_file.inspect}"
  if uploaded_file.present?
    file_path = Rails.root.join('tmp', uploaded_file.original_filename)
    p "the file path is: #{file_path}"
    File.open(file_path, 'wb') { |f| f.write(uploaded_file.read) }
    p "File saved to: #{file_path}"
    # push job (redis) to allow sidekiq to consume and perform in order of queue
    CsvImportWorker.perform_async(file_path.to_s)
    p "CSV import job enqueued with file path: #{file_path}"
    redirect_to info_path, notice: "CSV upload started. Processing in background."
  else
    redirect_to info_path, alert: "Please select a CSV file to upload."
  end
  end
end