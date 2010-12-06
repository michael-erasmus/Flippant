require File.join(File.dirname(__FILE__), %w[.. spec_helper]) 

feature "Simple Flippant Dsl" do
  background do 
    class Person
    end
    class Animal 
      attr_reader :species
      def initialize(species)
        @species = species
      end
    end 
  end

  scenario "module level method that maps to a specified constant" do 
    Flippant.dsl_method :person, Person 
    person.should be_a_kind_of Person
  end

  scenario "module level method that maps to a specified lambda" do 
    Flippant.dsl_method :person do
      maps_to{Person.new}
    end
    person.should be_a_kind_of Person
  end

  scenario "method that uses hash arguments" do 
    Flippant.dsl_method :name => :person, :maps_to => Person
    person.should be_a_kind_of Person
  end

  scenario "module level that returns the default OpenStruct" do
    Flippant.dsl_method :person 
    person.should be_a_kind_of OpenStruct 
  end

  scenario "class level that returns the default OpenStruct" do
    Person.dsl_method :dsl 
    instance = Person.dsl
    instance.should be_a_kind_of OpenStruct 
  end

  scenario "dsl that instanciates a class with constructor arguments" do
    Flippant.dsl_method :name => :animal, :maps_to => Animal
     animal("homo sapien").species.should == "homo sapien"
  end
end
