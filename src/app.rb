class App < Sinatra::Base

    def db
        if @db == nil
            @db = SQLite3::Database.new('./db/db.db')
            @db.results_as_hash = true
        end
        return @db
    end

    get '/' do
        @user = db.execute('SELECT  FROM Contact')
        erb :index
    end

    
end