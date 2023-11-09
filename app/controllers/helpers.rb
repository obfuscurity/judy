
module Judy
  class Web < Sinatra::Base

    helpers do

      # Auth helpers
      def protected!
        return if authorized? || cfp_submission?
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
      def cfp_submission?
        request.path.eql?('/abstracts/new') &&
        request.request_method.eql?('POST') &&
        request.form_data? && !request.forwarded?
      end
      def user_is_admin?
        ENV['JUDY_ADMIN'].split(',').each do |admin|
          return true if admin.eql?(@auth.credentials.first)
        end
        return false
      end
      def user_is_chair?
	return true if user_is_admin?
        ENV['JUDY_CHAIR'].split(',').each do |chair|
	  return true if chair.eql?(@auth.credentials.first)
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

      # Mail helpers
      def mail_cfp_acknowledgement?
        !ENV['POSTMARK_API_TOKEN'].nil? && !ENV['MAIL_FROM_ADDRESS'].nil? && !ENV['POSTMARK_TEMPLATE_ID'].nil?
      end

      def mail_cfp_acknowledgement(args)
        client = Postmark::ApiClient.new(ENV['POSTMARK_API_TOKEN'])
        client.deliver_with_template(
          track_opens: true,
          message_stream: 'outbound',
          from: ENV['MAIL_FROM_ADDRESS'],
          to: args[:recipient],
          template_id: ENV['POSTMARK_TEMPLATE_ID'],
          template_model: {
            title: args[:title],
            body: args[:body]
          }
        )
        puts error
      end
    end
  end
end

