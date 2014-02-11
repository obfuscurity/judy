
module Judy
  class Web < Sinatra::Base

    get '/scores/?' do
      Score.all.to_json
    end

    get '/scores/:id/?' do
      begin
        @score = Score[params[:id]].first
        status 200
        @score.to_json
      rescue => e
        halt 404
      end
    end

    post '/scores/?' do
      begin
        @score = Score.new(params).save
        status 200
        @score.to_json
      rescue => e
        p e.message
        halt 400
      end
    end

    put '/scores/:id/?' do
      begin
        @score = Score[params[:id]].first
        @score.update(params).save
        status 200
        @score.to_json
      rescue => e
        halt 404
      end
    end

    delete '/scores/:id/?' do
      begin
        Score[params[:id]].destroy
        status 204
      rescue => e
        halt 404
      end
    end
  end
end
