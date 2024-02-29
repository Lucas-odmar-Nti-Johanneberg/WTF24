class App < Sinatra::Base

    def db
        if @db == nil
            @db = SQLite3::Database.new('./db/db.db')
            @db.results_as_hash = true
        end
        return @db
    end

    get '/' do
        @users = db.execute("SELECT * FROM user")
        erb :index
    end

    get '/catches/:id' do |id|
        @catches = db.execute('SELECT * FROM catch WHERE user_id = ?', id)
        erb :catches
    end
    
end