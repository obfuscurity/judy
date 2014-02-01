
module Judy
  class Web < Sinatra::Base

    get '/events/?' do
      @events = Event.all
      status 200
      erb :'events/index', :locals => { :events => @events }
    end

    get '/events/:id/?' do
      @event = Event[params[:id]]
      status 200
      erb :'events/show', :locals => { :event => @event }
    end

    post '/events/?' do
      begin
        @event = Event.new(params).save
        status 200
        @event.to_json
      rescue => e
        p e.message
        halt 400
      end
    end

    put '/events/:id/?' do
      begin
        @event = Event[params[:id]].first
        @event.update(params).save
        status 200
        @event.to_json
      rescue => e
        halt 404
      end
    end

    delete '/events/:id/?' do
      begin
        Event[params[:id]].destroy
        status 204
      rescue => e
        halt 404
      end
    end
  end
end
