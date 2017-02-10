class Token
    require 'securerandom'
    require 'redis'
    require 'json'

    include ActiveModel::Model

    EXPIRATION_TIME = 15

    attr_accessor :user_id, :access_token, :refresh_token, :ikm, :salt, :expires_at

    def self.generate(user_id)
        token = Token.new(
            user_id: user_id,
            ikm: SecureRandom.base64(32),
            salt: SecureRandom.base64(32),
            access_token: SecureRandom.urlsafe_base64(64, false),
            refresh_token: SecureRandom.urlsafe_base64(64, false),
            expires_at: (Time.now + EXPIRATION_TIME.minutes).to_i
        )

        if (token.save())
            return token
        end

        return false
    end

    def self.find(access_token)
        redis = Redis.new(:host => '127.0.0.1', :port => 6379, :db => 0)
        data = redis.get("access_token:" + access_token)
        if data == nil
            return nil
        end

        data = JSON.parse(data)
        return Token.new(
            user_id: data['data'][0],
            ikm: data['data'][1],
            salt: data['data'][2],
            access_token: data['data'][3],
            refresh_token: data['data'][4],
            expires_at: data['data'][5]
        )
    end

    def save
        redis = Redis.new(:host => '127.0.0.1', :port => 6379, :db => 0)
        return redis.set("access_token:" + self.access_token, self.to_json)
    end

    def delete
        redis = Redis.new(:host => '127.0.0.1', :port => 6379, :db => 0)
        return redis.del("access_token:" + self.access_token)
    end

    def isExpired
        return self.expires_at < Time.now.to_i
    end

    def self.json_create(o)
        new(*o['data'])
    end

    def to_json(*a)
        {
            'json_class' => self.class.name,
            'data' => [
                user_id,
                ikm,
                salt,
                access_token,
                refresh_token,
                expires_at
            ]
        }.to_json(*a)
    end
end