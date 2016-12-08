
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
      def mail_body
        "Greetings!\n\n
        On behalf of the Monitorama team, I want to personally thank you for
        submitting your proposal for our upcoming event. Your abstract has been
        successfully recorded, and we expect to review it in the coming weeks.
        We should finish our deliberations by Feb 15, 2017, and we will send out
        notifications shortly thereafter.\n\n
        Please note that you're allowed, nay, *encouraged*, to submit multiple
        proposals. We're very excited to see what sort of proposals come in this
        year. Regardless of the outcome, we hope that you're making plans to
        join us in Portland for this event.\n\n
        Best wishes,\n\n
        Jason Dixon\n
        Monitorama PDX 2017"
      end
      def mail_cfp_acknowledgement(recipient)
        message = Mail.new do
          to      recipient
          from    'Monitorama PDX 2017 <info@monitorama.com>'
          subject 'Monitorama PDX 2017 - CFP Submission Received'
          body    mail_body

          delivery_method Mail::Postmark, :api_token => ENV['POSTMARK_API_TOKEN']
        end
        message.deliver
      end
    end
  end
end

