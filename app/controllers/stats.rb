
module Judy
  class Web < Sinatra::Base
    
    get '/health' do
      content_type :json
      { 'status' => 'ok' }.to_json
    end
  end
end

