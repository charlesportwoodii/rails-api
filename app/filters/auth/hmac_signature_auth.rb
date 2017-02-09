class HMACSignatureAuth
    require 'securerandom'
    
    DATE_HEADER = 'X-DATE'
    AUTHORIZATION_HEADER = 'Authorization'
    DRIFT_TIME_ALLOWANCE = 90
    HKDF_ALGO = 'sha256'
    AUTH_INFO = 'HMAC|AuthenticationKey'

    def self.authenticate(request)
        return true
    end
end