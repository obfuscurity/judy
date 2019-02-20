
module Judy
  class Web < Sinatra::Base

    get '/scores/?' do
      @sort = params[:sort] || 'mean'
      @abstracts = Abstract.fetch_all_abstracts_and_scores(:sort => @sort)
      status 200
      erb :'scores/index', :locals => { :abstracts => @abstracts, :sort => @sort, :user => session[:user] }
    end
  end
end
