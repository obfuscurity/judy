
module Judy
  class Web < Sinatra::Base

    get '/speakers/?' do
      Speaker.all.to_json
    end

    get '/speakers/:id/?' do
      begin
        @speaker = Speaker[params[:id]].first
        status 200
        @speaker.to_json
      rescue => e
        halt 404
      end
    end

    post '/speakers/?' do
      begin
        @speaker = Speaker.new(params).save
        status 200
        @speaker.to_json
      rescue => e
        p e.message
        halt 400
      end
    end

    put '/speakers/:id/?' do
      begin
        @speaker = Speaker[params[:id]].first
        @speaker.update(params).save
        status 200
        @speaker.to_json
      rescue => e
        halt 404
      end
    end

    delete '/speakers/:id/?' do
      begin
        Speaker[params[:id]].destroy
        status 204
      rescue => e
        halt 404
      end
    end
  end
end
