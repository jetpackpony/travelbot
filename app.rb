require 'sinatra/base'

module TravelBot
  class App < Sinatra::Base
    set :public_folder, File.dirname(__FILE__) + '/public'

    get '/' do
      erb :"index.html"
    end
  end
end
