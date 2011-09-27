require 'rubygems'
require 'sinatra'
require 'csv'
require_relative 'partials'

helpers Sinatra::Partials

class Collection
  attr_accessor :species, :distances
  
  def initialize(species_file, distances_file)
    @species = []
    @distances = []
    
    CSV.foreach(species_file) do |s|
      @species << Species.new(s)
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
end

collection = Collection.new('primates.csv', 'primates_dist.csv')

get '/' do
  @collection = collection
  erb :home
end

post '/phylogeny' do
  @collection = collection
  unless params[:species].nil?
    species_ids = params[:species].collect {|s| s[0].to_i}
    @species = collection.species.select {|s| species_ids.include?(s.id)}
  end
  erb :phylogeny
end