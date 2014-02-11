
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
      def dataset_total_complete
        total_complete = Score.all.count / (Abstract.all.count * judges.count.to_f) * 100
        return total_complete.nan? ? '0.0, 100.0' : "#{total_complete.round(2)}, #{(100 - total_complete).round(2)}"
      end
      def dataset_user_complete
        user_complete = Score.filter(:judge => session[:user]).all.count.to_f / Abstract.all.count * 100
        return user_complete.nan? ? '0.0, 100.0' : "#{user_complete.round(2)}, #{(100 - user_complete).round(2)}"
      end
      def dataset_score_distribution
        return Score.all.reduce([]) {|a,score| a[score.count] ||= 0; a[score.count] += 1; a}.map {|c| c.to_i}.join(',')
      end
    end
  end
end

