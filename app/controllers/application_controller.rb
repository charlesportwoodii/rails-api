class ApplicationController < ActionController::API
    require 'hmac_signature_auth'

    protected

        def auth
            result = HMACSignatureAuth.authenticate(request)
            if result == false
                return render :status => :unauthorized
            end
            @@access_token = result['access_token']
            @@user = result['user']
        end
end
