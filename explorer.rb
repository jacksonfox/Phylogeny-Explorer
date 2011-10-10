require 'rubygems'
require 'sinatra'
require 'csv'
require 'yaml'
require_relative 'partials'

helpers Sinatra::Partials

DATA_DIR = '/public/data/'
DATA_URL = '/data/'

class Collection
  attr_accessor :species, :distances, :name, :url
  
  def initialize(collection_name)
    config_file = File.join(Dir.pwd, DATA_DIR, collection_name, 'config.yml')
    config = YAML.load_file(config_file)
        
    @name = config['name']
    @url = File.join(DATA_URL, collection_name)
    
    base_path = File.join(Dir.pwd, DATA_DIR, collection_name)

    species_file = File.join(base_path, config['species_file'])
    distances_file = File.join(base_path, config['distances_file'])
        
    @species = []
    @distances = []
    
    CSV.foreach(species_file) do |s|
      @species << CollectionSpecies.new(s, self)
    end    
    
    CSV.foreach(distances_file) do |d|
      @distances << {
        :s1 => d[0],
        :s2 => d[1],
        :distance => d[2]
      }
    end    
  end
  
  def distance_between(s1, s2)
    distance_pair = @distances.select { |d| (d[:s1] == s1 && d[:s2] == s2) || d[:s2] == s1 && d[:s1] == s2 }
    distance_pair.first[:distance]
  end
  
  def distances_from(s1, *other_species)
    distances_from = []
    other_species.each do |s2|
      distances_from << [s2.name, distance_between(s1.name, s2.name)]    
    end
    distances_from
  end
  
  # todo: screws up the previous method for some reason
  # def distances_from(s1)
  #   distances_from = []
  #   other_species = @species.select { |s2| s2 != s1 }
  #   other_species.each do |s2|
  #     distances_from << [s2.name, distance_between(s1.name, s2.name)]
  #   end
  #   distances_from
  # end
end

class CollectionSpecies
  attr_accessor :id, :name, :wiki_link, :div_link, :collection
  
  def initialize(data, collection)
    @id = data[0].to_i
    @name = data[1]
    @image = data[2]
    @wiki_link = data[3]
    @div_link = data[4]
    @collection = collection
  end
  
  def image
    File.join(@collection.url, @image)
  end
end

helpers do
end

collection = Collection.new('primates')

get '/' do
  erb :home
end

get '/explore' do
  @collection = collection
  erb :explore
end

post '/view' do
  @collection = collection
  unless params[:species].nil?
    species_ids = params[:species].collect {|s| s[0].to_i}
    @species = collection.species.select {|s| species_ids.include?(s.id)}
  end
  erb :view
end