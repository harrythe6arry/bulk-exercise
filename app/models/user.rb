# class User < ApplicationRecord
#   belongs_to :account
#   has_secure_password # Handles password hashing and validation

#   # A custom class method to find a user by email and verify their password.
#   # The `&.` is a safe navigation operator to prevent errors if the user is not found.
#   def self.authenticate(email, password)
#     user = find_by(email: email)
#     user if user&.authenticate(password)
#   end

#   # Validations can be added here, e.g., for email format, presence of name, etc.
#   validates :email, presence: true, uniqueness: true
#   validates :name, presence: true
#   validates :password, presence: true, length: { minimum: 6 }
# end