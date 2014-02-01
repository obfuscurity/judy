
module Judy
  class Web < Sinatra::Base

    configure do
      enable :logging
      use Rack::SslEnforcer if ENV['FORCE_HTTPS']
    end

    before do
      protected!
    end
  end
end

