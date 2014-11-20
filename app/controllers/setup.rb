
module Judy
  class Web < Sinatra::Base

    configure do
      enable :logging
      enable :sessions
      enable :cross_origin
      use Rack::SslEnforcer if ENV['FORCE_HTTPS']
      use Rack::Flash
      disable :protection
      #set :protection, :except => [:http_origin, :remote_token]
    end

    before do
      protected!
    end
  end
end

