Rails.application.routes.draw do
  scope '/api' do
    scope '/v1' do
      scope '/user' do
        post '/authenticate' => 'user#authenticate'
        post '/register' => 'user#register'
        post '/refresh' => 'user#refresh'
      end
    end
  end
end
