require 'sinatra'
require 'rack-ssl-enforcer'
require 'rack-flash'
require 'json'

require 'models/init'

module Judy
  class Web < Sinatra::Base

    require 'controllers/setup'
    require 'controllers/helpers'
    require 'controllers/abstracts'
    require 'controllers/scores'

    get '/' do
      erb :index, :locals => {
        :dataset_total_complete => dataset_total_complete,
        :dataset_score_distribution => dataset_score_distribution
      }
    end
  end
end

