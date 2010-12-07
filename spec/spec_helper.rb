require 'steak'
require File.join(File.dirname(__FILE__), %w[.. lib flippant]) 
include Flippant

#Test classes
class Person
  attr_accessor :name
end
class Animal 
attr_reader :species
attr_accessor :location

def initialize(species)
  @species = species
end
end 
