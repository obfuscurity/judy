
module Judy

  class JudgingComplete < RuntimeError ; end

  class Web < Sinatra::Base

    get '/abstracts/?' do
      @abstracts = Abstract.fetch_all_abstracts_and_scores
      status 200
      erb :'abstracts/index', :locals => { :abstracts => @abstracts }
    end

    get '/abstracts/new/?' do
      status 200
      erb :'abstracts/new'
    end

    get '/abstracts/next/?' do
      begin
        @abstract = Abstract.fetch_one_random_unscored_by_user(session[:user])
        redirect to "/abstracts/#{@abstract.id}"
      rescue Judy::JudgingComplete
        p "user #{session[:user]} has finished judging all abstracts"
        redirect to '/'
      end
    end

    get '/abstracts/:id/?' do
      @abstract = Abstract.fetch_one_abstract_with_score_by_judge(:id => params[:id], :judge => session[:user])
      status 200
      erb :'abstracts/show', :locals => { :abstract => @abstract }
    end

    post '/abstracts/new/?' do
      begin
        @speaker = Speaker.new(:full_name => params[:full_name], :email => params[:email]).save
        @abstract = Abstract.new(:title => params[:title], :body => params[:body], :speaker_id => @speaker.id, :event_id => 1).save
        status 200
        erb :'abstracts/new', :locals => { :alert => { :type => 'success', :message => 'Abstract successfully added' } }
      rescue => each
        p e.message
        halt 401
      end
    end

    post '/abstracts/:abstract_id/scores/?' do
      begin
        content_type 'application/json'
        @score = Score.upsert(:judge => session[:user], :count => params[:count], :abstract_id => params[:abstract_id])
        status 204
      rescue => e
        p e.message
        halt 401
      end
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
