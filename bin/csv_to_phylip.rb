#!/usr/bin/ruby
#
# Convert .dist files to phylip dist format
#

require 'rubygems'
require 'csv'

def distance_between(s1, s2)
  if (s1 == s2)
    return 0.0
  else 
    distance_pair = $distances.select { |d| (d[:s1] == s1 && d[:s2] == s2) || d[:s2] == s1 && d[:s1] == s2 }
    return distance_pair.first[:distance]
  end
end

def distances_from(s1, *other_species)
  distances_from = []
  other_species.each do |s2|
    distances_from << [s2, distance_between(s1, s2)]    
  end
  distances_from
end

if ARGV.length != 2
  puts 'Usage: phylip_converter.rb [original file] [output file]'
  exit
end

distances_file = ARGV[0]
output_file = ARGV[1]
$distances = []

CSV.foreach(distances_file) do |d|
  $distances << {
    :s1 => d[0],
    :s2 => d[1],
    :distance => d[2]
  }
end

species = $distances.collect{|d| d[:s1]}.uniq

output = File.open(output_file, 'w')

output.puts " #{species.count}"
species.each do |s|
  from_each = distances_from(s, *species).map{|s2| s2[1].to_s}
  output.puts "#{s} #{from_each.join(' ').strip}"
end

