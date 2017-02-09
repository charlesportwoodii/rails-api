class User < ApplicationRecord
  validates :password, :email, :username, :presence =>true
  validates_uniqueness_of :email
  validates_uniqueness_of :username

  def verify_password(password)
    return Argon2::Password.verify_password(password, self.password)
  end
end
