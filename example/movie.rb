require_relative "../lib/flippant"

#Say you have this
class Movie
  attr_accessor :name
  attr_accessor :actors

  def initialize(name)
    @name = name
  end

  def describe
    <<-eos
      The movie name is #{@name}
      It's directed by #{@director.name}
      Actors: #{@actors.map{|a| a.name}}
    eos
  end
end

class Director
  attr_accessor :name
end

class Actor
  attr_accessor :name

  def initialize(name)
    @name = name
  end
end

#And you describe your DSL like this
Flippant.dsl_method :movie, Movie do

  assign_property_method :name => :directed_by, :property_name => :director,:maps_to => Director 

  add_item_method :name => :starring, :collection_name => :actors, :maps_to => Actor do
    add_item_method :name => :also_stars_in, :collection_name => :movies, :maps_to => Movie
  end
end

#Then you can do stuff like

include Flippant

fight_club = movie "Fight Club" do
  directed_by :name => "David Fincher"
  starring "Brad Pitt" do
    also_stars_in "Inglourious Basterds"
    also_stars_in "Babel"
  end
  starring "Edward Norton"
end
puts fight_club.describe

#You can also use class methods if you prefer
Movie.dsl_method :name => :describe do
  add_item_method :name => :has_actor, :maps_to => Actor do
    add_item_method :name => :also_stars_in, :maps_to => Movie
  end
end

#Argument style DSL methods are also supported
Movie.describe "Pulp Fiction" do |m|
  m.has_actor "Samuel L Jackson"
  m.has_actor "Uma Thurman"
end
