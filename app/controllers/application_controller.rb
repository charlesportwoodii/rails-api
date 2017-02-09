class ApplicationController < ActionController::API
    require 'hmac_signature_auth'
    protected
        def auth
            if HMACSignatureAuth.authenticate(request) == false
                return render :status => :unauthorized
            end

            return true
        end
end
