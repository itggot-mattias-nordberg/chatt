class App < Sinatra::Base
	enable :sessions
	get '/' do
		"Hello, Grillkorv!"

		slim(:index, locals:{ user_infogreeting: "Hello from index!" })
	end

         

	post '/login' do
		db = SQLite3::Database.new("chatt.sqlite") 
		username = params["username"] 
		password = params["password"]
		accounts = db.execute("SELECT * FROM users WHERE username=?", username)
		account_password = BCrypt::Password.new(accounts[0][2])

		if account_password == password
			result = db.execute("SELECT id FROM users WHERE username=?", [username]) 
			session[:id] = accounts[0][0] 
			session[:login] = true 
		elsif password == nil
			redirect("/error")
		else
			session[:login] = false
		end
		redirect('/users')
	end

	get '/users' do
		slim(:login)
	end

	get '/register' do
		slim(:register) 
	end

	post '/register' do
		db = SQLite3::Database.new('chatt.sqlite')
		username = params["username"]
		password = params["password"]
		confirm = params["password2"]
		if confirm == password
			begin
				password_encrypted = BCrypt::Password.create(password)
				db.execute("INSERT INTO users('username' , 'password') VALUES(? , ?)", [username,password_encrypted])
				redirect('/signup_successful')

			rescue 
				session[:message] = "Username is not available"
				redirect("/error")
			end
		else
			session[:message] = "Password does not match"
			redirect("/error")
		end
	end

	post '/logout' do 
		session[:login] = false
		session[:id] = nil
		redirect('/')
	end

	get '/signup_successful' do
		slim(:signup_successful)
	end

	get '/error' do
		slim(:error)
	end
end