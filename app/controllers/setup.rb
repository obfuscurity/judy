
module Judy
  class Web < Sinatra::Base

    configure do
      enable :logging
      enable :sessions
      use Rack::SslEnforcer if ENV['FORCE_HTTPS']
      use Rack::Flash
      set :protection, :origin_whitelist => ['http://127.0.0.1:8000']
    end

    before do
      protected!
    end
  end
end

