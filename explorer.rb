require 'rubygems'
require 'sinatra'
require 'partials'

helpers Sinatra::Partials

species = [
  {
    :id => 1,
    :name => 'Dog',
    :image => 'dog.jpeg'
  },
  {
    :id => 2,
    :name => 'Cat',
    :image => 'cat.jpeg'
  }
]

get '/' do
  @species = species
  erb :home
end

post '/phylogeny' do
  unless params[:species].nil?
    species_ids = params[:species].collect {|s| s[0].to_i}
    @species = species.select {|s| species_ids.include?(s[:id])}
  end
  erb :phylogeny
end