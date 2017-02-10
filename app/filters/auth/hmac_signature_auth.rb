class HMACSignatureAuth
    require 'securerandom'
    require 'base64'
    require 'hkdf'
    require 'date'
    require 'digest'
    require 'openssl'
    require 'fast_secure_compare/fast_secure_compare'

    DATE_HEADER = 'X-DATE'
    AUTHORIZATION_HEADER = 'Authorization'
    DRIFT_TIME_ALLOWANCE = 90
    HKDF_ALGO = 'SHA256'
    AUTH_INFO = 'HMAC|AuthenticationKey'

    def self.authenticate(request)
        header = request.headers[self::AUTHORIZATION_HEADER]
        if header == nil
            return false
        end

        authorization = header.sub('HMAC ', '').split(',')

        if (authorization.length != 3) 
            return false
        end

        access_token = authorization[0]
        hmac = Base64.decode64(authorization[1])
        salt = Base64.decode64(authorization[2])

        token = Token.find(access_token)
        if token == nil
            return false
        end

        signatureIsValid = self.IsHMACSignatureValid(access_token, Base64.strict_decode64(token.ikm), salt, request, hmac)

        if signatureIsValid

            user = User.find_by_id(token.user_id)
            if user == nil
                return false
            end

            return {
                'access_token' => access_token,
                'user' => user
            }
        end

        return false
    end

    def self.IsHMACSignatureValid(access_token, ikm, salt, request, hmac)
        if hmac == nil
            return false
        end

        hkdf = HKDF.new(ikm, :salt => salt, :algorithm => self::HKDF_ALGO, :info => self::AUTH_INFO).next_bytes(32)

        date = request.headers[self::DATE_HEADER]
        if date == nil
            return false
        end

        drift = self.GetTimeDrift(date.to_datetime.to_i)

        if drift > self::DRIFT_TIME_ALLOWANCE
            return false
        end

        json = request.raw_post
        request.body.rewind
        
        signatureString = (Digest::SHA256.hexdigest(json) << "\n" << request.method << "+" << request.fullpath << "\n" << date << "\n" << Base64.strict_encode64(salt))
        
        selfHMAC = OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), hkdf, signatureString)
        
        return FastSecureCompare.compare(selfHMAC, hmac)
    end

    def self.GetTimeDrift(time)
        current = Time.now.to_i
        return (current - time).abs
    end
end