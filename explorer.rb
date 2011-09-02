require 'rubygems'
require 'sinatra'
require 'csv'
require_relative 'partials'

helpers Sinatra::Partials

class Species
  attr_accessor :id, :name, :image, :wiki_link, :div_link
  def initialize(arr)
    @id = arr[0].to_i
    @name = arr[1]
    @image = arr[2]
    @wiki_link = arr[3]
    @div_link = arr[4]
  end
end

helpers do
  def load_species(path)
    species = []
    CSV.foreach(path) do |row|
      species << Species.new(row)
    end
    return species
  end
end

get '/' do
  @all_species = load_species('primates.csv')
  erb :home
end

post '/phylogeny' do
  all_species = load_species('primates.csv')
  unless params[:species].nil?
    species_ids = params[:species].collect {|s| s[0].to_i}
    @species = all_species.select {|s| species_ids.include?(s.id)}
  end
  erb :phylogeny
end