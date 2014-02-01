
module Judy
  class Web < Sinatra::Base

    get '/abstracts/?' do
      @abstracts = Abstract.fetch_abstracts_with_related
      status 200
      erb :'abstracts/index', :locals => { :abstracts => @abstracts }
    end

    get '/abstracts/new/?' do
      status 200
      erb :'abstracts/new'
    end

    get '/abstracts/:id/?' do
      @abstract = Abstract[params[:id]]
      status 200
      erb :'abstracts/show', :locals => { :abstract => @abstract }
    end

    post '/abstracts/new/?' do
      @speaker = Speaker.new(:full_name => params[:full_name], :email => params[:email]).save
      @abstract = Abstract.new(:title => params[:title], :body => params[:body], :speaker_id => @speaker.id, :event_id => 1).save
      status 200
      erb :'abstracts/new', :locals => { :alert => { :type => 'success', :message => 'Abstract successfully added' } }
    end

    put '/abstracts/:id/?' do
      @abstract = Abstract[params[:id]]
      @abstract.update(params).save
      status 200
      erb :'abstracts/show', :locals => { :abstract => @abstract }
    end

    delete '/abstracts/:id/?' do
      Abstract[params[:id]].destroy
      status 200
      redirect to '/abstracts'
    end
  end
end
