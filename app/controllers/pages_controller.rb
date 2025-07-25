class PagesController < ApplicationController
  http_basic_authenticate_with name: "harry", password: "12345", only: :info
  include Sidekiq::Worker

  def index
  end

  def info
    @bulk_charge = BulkCharge.new
    @uploaded_files = BulkCharge.all.order(created_at: :desc)
    @message = "This is a simple user authentication system using HTTP Basic Authentication."
  end
  
end