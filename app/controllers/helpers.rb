
module Judy
  class Web < Sinatra::Base

    helpers do
      def protected!
        return if authorized?
        headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
        halt 401
      end
      def authorized?
        @auth ||=  Rack::Auth::Basic::Request.new(request.env)
        @auth.provided? and @auth.basic? and @auth.credentials and authenticated?
      end
      def authenticated?
        ENV['JUDY_AUTH'].split(',').each do |pair|
          return true if (pair.split(':') == @auth.credentials)
        end
        return false
      end
      def json!
        return if request.xhr?
        halt 404
      end
    end
  end
end

