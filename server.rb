require 'sinatra'
require 'pg'
require 'pry'
require 'sinatra/flash'

enable :sessions

def db_connection
  begin
    connection = PG.connect(dbname: "urls")
    yield(connection)
  ensure
    connection.close
  end
end

def get_urls
  db_connection { |conn| conn.exec("SELECT * FROM urls") }
end

def create_short_url
  random_url = ""
  4.times do
    random_url += ("a".."z").to_a.sample
    random_url += ("0".."9").to_a.sample
  end 

  if unique_random_url?(random_url)
    return random_url
  else
    create_short_url
  end
end

def unique_long_url?(url)
  result = db_connection do |conn|
    conn.exec("SELECT * FROM urls WHERE long_url = $1", [url])
  end
  result.to_a.empty?
end

def unique_random_url?(url)
  results = db_connection do |conn| 
   conn.exec("SELECT * FROM urls WHERE short_url = $1;", [url])
  end
  results.to_a.empty?
end

get "/" do
  erb :index, locals: { urls: get_urls }
end

post "/" do
  long_url = params[:long_url]
  short_url = create_short_url

  if unique_long_url?(long_url)
    db_connection do |conn|
      conn.exec_params("INSERT INTO urls (long_url, short_url) VALUES ($1, $2)", [long_url, short_url])
    end
    redirect "/"
  else
    flash[:error] = "Hey, that URL has already been submitted!"
    redirect "/"
  end
end

get "/:short_url" do
  short_url = params[:short_url]

  long_result = db_connection do |conn|
    conn.exec("SELECT long_url FROM urls WHERE short_url = $1", [short_url])
  end
  long_url = long_result.first["long_url"]

  redirect long_url
end





