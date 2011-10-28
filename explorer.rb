require 'rubygems'
require 'csv'
require 'yaml'
require 'vendor/sinatra/lib/sinatra.rb'
require File.join(File.dirname(__FILE__), 'partials')

helpers Sinatra::Partials

TEMP_DIR = '/public/tmp/'
DATA_DIR = '/public/data/'
DATA_URL = '/data/'

class Collection
  attr_accessor :species, :name, :url, :distances
  
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
    distance = 0.0
    if (s1 != s2)
      distance_pair = @distances.select { |d| (d[:s1] == s1 && d[:s2] == s2) || d[:s2] == s1 && d[:s1] == s2 }
      distance = distance_pair.first[:distance]
    end
    return distance
  end
  
  def distances_from(s1, *other_species)
    distances_from = []
    other_species.each do |s2|
      distances_from << [s2.name, distance_between(s1.name, s2.name)]
    end
    return distances_from
  end
  
  def find_by_id(id)
    species = @species.select{ |s| s.id == id }
    return species.first
  end

  def find_by_name(name)
    species = @species.select{ |s| s.name == name }
    return species.first
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
  def generate_tempfile_name(prefix=nil, suffix=nil)
    t = Time.now.strftime("%Y%m%d")
    filename = "#{prefix}#{t}-#{$$}-#{rand(0x100000000).to_s(36)}#{suffix}"
  end
  def write_distances_file(collection, *species_ids)    
    output_file = File.join(Dir.pwd, TEMP_DIR, generate_tempfile_name(nil,".dist"))
    output = File.open(output_file, 'w')
    species = species_ids.map{ |s| collection.find_by_id(s) }

    # Output distance matrix in phylip format
    output.puts " #{species.length}"
    species.each do |s|
      from_each = collection.distances_from(s, *species).map{|s2| s2[1].to_s}
      output.puts "#{s.name} #{from_each.join(' ').strip}"
    end
    
    # Close the IO to make sure buffer is flushed, then return path to file
    output.close    
    return output_file
  end
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
  species_ids = params[:species].split(',').map{ |id| id.to_i }
  distances_file = write_distances_file(collection, *species_ids)
  status 200
  output = `bin/make_tree.pl --file #{distances_file}`
  body(output)
end

post '/get_image' do
  species_name = params[:species]
  image = collection.find_by_name(species_name).image
  status 200
  body(image)
end

post '/view' do
  @collection = collection
  unless params[:species].nil?
    species_ids = params[:species].collect {|s| s[0].to_i}
    @species = collection.species.select {|s| species_ids.include?(s.id)}
  end
  erb :view
end