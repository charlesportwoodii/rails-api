class UserController < ApplicationController
  require 'securerandom'

  # Require authentication on all actions except for the authenticate method
  before_action :auth, only: [ 'refresh' ]

  # Super simple authentication with Argon2i hash
  def authenticate
    form = LoginForm.new(email: params['email'], password: params['password'])

    if form.login
      return render json: {
        'ikm' => form.token.ikm,
        'salt' => form.token.salt,
        'access_token' => form.token.access_token,
        'refresh_token' => form.token.refresh_token,
        'expires_at' => form.token.expires_at
      }, status: 200
    end

    render :status => :unauthorized
  end

  def refresh
    oldToken = Token.find(@@access_token)
    newToken = Token.generate(@@user.id)

    oldToken.delete()

    return render json: {
        'ikm' => newToken.ikm,
        'salt' => newToken.salt,
        'access_token' => newToken.access_token,
        'refresh_token' => newToken.refresh_token,
        'expires_at' => newToken.expires_at
      }, status: 200
  end

  # Trivial registration with a given username, email. and password
  def register
    u = User.new(
      email: params['email'],
      username: params['username'],
      password: Argon2::Password.new(t_cost: 3, m_cost: 10).create(params['password'])
    )

    render json: {
      'status' => u.save()
    }, status: 200
  end
end
