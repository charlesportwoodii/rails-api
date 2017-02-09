class HMACSignatureAuth
    require 'securerandom'
    require "base64"

    DATE_HEADER = 'X-DATE'
    AUTHORIZATION_HEADER = 'Authorization'
    DRIFT_TIME_ALLOWANCE = 90
    HKDF_ALGO = 'sha256'
    AUTH_INFO = 'HMAC|AuthenticationKey'

    def self.authenticate(request)

        date = request.headers[self::DATE_HEADER]
        authorization = request.headers[self::AUTHORIZATION_HEADER].sub('HMAC ', '').split(',')

        if (authorization.length != 3) 
            return false
        end

        access_token = authorization[0]
        hmac = Base64.decode64(authorization[1])
        salt = Base64.decode64(authorization[2])

        return true
    end
end