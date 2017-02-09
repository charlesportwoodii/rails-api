class LoginForm 
    include ActiveModel::Model

    attr_accessor :email, :password, :otp, :token
    validates :email, :password, presence: true

    def login
        if self.valid?
            u = User.find_by(email: self.email)
            if u == nil
                return false
            end
            
            if u.verify_password(self.password)
                self.token = Token.generate(u.id)
                return true
            end
        end

        return false
    end
end