
module Judy
  class Web < Sinatra::Base

    configure do
      enable :logging
      enable :sessions
      use Rack::SslEnforcer if ENV['FORCE_HTTPS']
    end

    before do
      protected!
    end
  end
end

