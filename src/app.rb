class App < Sinatra::Base

    enable :sessions

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
        query = "SELECT catch.*, fish.art FROM catch
                INNER JOIN fish
                ON catch.fish_id = fish.id
                WHERE user_id = ?"

        @catches = db.execute(query, id)
        @id = id.to_i 
        erb :catches
    end


    get '/register/:id' do |id|
        if (session[:user_id] == id.to_i)
            @fishes = db.execute("SELECT * FROM fish")
            @id = id
            erb :register
        end
    end 

    post '/register' do 
        datum = params['datum'] 
        plats = params['plats'] 
        vikt = params['vikt'] 
        fish_id = params['art'].to_i
        user_id = params['id'].to_i
        query = 'INSERT INTO catch (datum, plats, vikt, fish_id, user_id) VALUES (?, ?, ?, ?, ?) RETURNING id'
        result = db.execute(query, datum, plats, vikt, fish_id, user_id).first 
        redirect "/catches/#{params['id']}" 
    end

    get '/login/user' do 
        erb :login
    end

    post '/catches/:user_id/delete/:catch_id' do |user_id, catch_id|
        # Perform deletion of catch with catch_id here
        # Example:
        db.execute("DELETE FROM catch WHERE id = ? AND user_id = ?", catch_id, user_id)
        redirect "/catches/#{user_id}"
    end

    get '/catches/edit/:catch_id' do |catch_id|
        # Retrieve the catch details for editing
        @catch = db.execute("SELECT * FROM catch WHERE id = ?", catch_id).first
        
        # Retrieve the user ID associated with this catch
        @id = @catch['user_id']
      
        # Retrieve all fishes for the dropdown
        @fishes = db.execute("SELECT * FROM fish")
      
        erb :catch_edit
    end
    
    post '/catches/:user_id/edit/:catch_id' do |user_id, catch_id|
        # Update the catch details based on the submitted form data
        datum = params['datum']
        plats = params['plats']
        vikt = params['vikt']
        fish_id = params['art'].to_i
    
        db.execute("UPDATE catch SET datum = ?, plats = ?, vikt = ?, fish_id = ? WHERE id = ?", datum, plats, vikt, fish_id, catch_id)
    
        redirect "/catches/#{user_id}"
    end
    
    get "/logout" do
        if(session[:username])
            session.clear
            redirect "/"
        end
    end  


    post '/login' do
        username = params['username']
        cleartext_password = params['password']
      
        user = db.execute('SELECT * FROM user WHERE username = ?', username).first
      
        if BCrypt::Password.new(user['password']) == cleartext_password
          session[:user_id] = user['id']
          session[:username] = user['username']
          session[:role] = user['role']
          redirect "/"
        else
          redirect "/login"  # Redirect to login page or display an error message
        end
      end
      

    get '/register_person' do 
        erb :register_person
    end

    post '/register_person' do 
        username = params['username']
        namn = params['namn']
        efternamn = params['efternamn']
        cleartext_password = params['password'] 
        role = params['role'] 

        hashed_password = BCrypt::Password.create(cleartext_password)

        query = 'INSERT INTO user (namn, efternamn, username, password, role) VALUES (?, ?, ?, ?, ?) RETURNING id'
        result = db.execute(query, namn, efternamn, username, hashed_password, role).first

        session[:user_id] = result
        session[:username] = username
        session[:role] = role
        
        redirect "/"
    end

end