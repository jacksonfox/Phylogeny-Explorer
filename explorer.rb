require 'rubygems'
require 'sinatra'
require 'csv'
require 'yaml'
require_relative 'partials'

helpers Sinatra::Partials

DATA_DIR = '/public/data/'
DATA_URL = '/data/'

class Collection
  attr_accessor :species, :name, :url, :distances_file
  
  def initialize(collection_name)
    config_file = File.join(Dir.pwd, DATA_DIR, collection_name, 'config.yml')
    config = YAML.load_file(config_file)
        
    @name = config['name']
    @url = File.join(DATA_URL, collection_name)
    
    base_path = File.join(Dir.pwd, DATA_DIR, collection_name)

    species_file = File.join(base_path, config['species_file'])
    @distances_file = File.join(base_path, config['distances_file'])
        
    @species = []
    @distances = []
    
    CSV.foreach(species_file) do |s|
      @species << CollectionSpecies.new(s, self)
    end    
  end
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

post '/generate' do
  distances_file = params[:file]
  exclude_species = params[:exclude]
  status 200
  output = `bin/make_tree.pl --file #{distances_file} --exclude #{exclude_species}`
  body(output)
end

post '/view' do
  @collection = collection
  unless params[:species].nil?
    species_ids = params[:species].collect {|s| s[0].to_i}
    @species = collection.species.select {|s| species_ids.include?(s.id)}
    @exclude = collection.species.select {|s| !species_ids.include?(s.id)}
  end
  erb :view
end