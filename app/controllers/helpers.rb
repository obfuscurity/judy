
module Judy
  class Web < Sinatra::Base

    helpers do

      # Auth helpers
      def protected!
        return if authorized? || request.xhr?
        headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
        halt 401
      end
      def authorized?
        @auth ||=  Rack::Auth::Basic::Request.new(request.env)
        @auth.provided? and @auth.basic? and @auth.credentials and authenticated?
      end
      def authenticated?
        ENV['JUDY_AUTH'].split(',').each do |pair|
          if (pair.split(':') == @auth.credentials)
            session[:user] = @auth.credentials.first
            return true
          end
        end
        return false
      end
      def judges
        ENV['JUDY_AUTH'].split(',').each.map {|a| a.split(':').first}
      end

      # Chart helpers
      def dataset_pct_complete
        pct_complete = Score.all.count / (Abstract.all.count * judges.count.to_f) * 100
        return "#{pct_complete}, #{100 - pct_complete}"
      end
    end
  end
end

