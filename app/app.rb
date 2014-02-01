require 'sinatra'
require 'rack-ssl-enforcer'
require 'json'

require 'models/init'

module Judy
  class Web < Sinatra::Base

    require 'controllers/setup'
    require 'controllers/helpers'
    require 'controllers/abstracts'
    require 'controllers/speakers'
    require 'controllers/events'

    get '/' do
      erb :index, :locals => {}
    end
  end
end

