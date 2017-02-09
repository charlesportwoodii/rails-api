class ApplicationController < ActionController::API
    protected
        def auth
            #render json: request.headers['Authorization'], status: 400
        end
end
