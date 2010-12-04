require File.join(File.dirname(__FILE__), %w[.. spec_helper]) 

feature "Simple Flippant Dsl" do
  background do 
    class Person
    end
  end

  scenario "Module level dsl method that maps to a specified constant" do |s|
    Flippant.dsl_method :person, Person 
    person.should be_a_kind_of Person
  end

  scenario "Module level dsl method that maps to a specified lambda" do |s|
    Flippant.dsl_method :person do
      maps_to{Person.new}
    end
    person.should be_a_kind_of Person
  end


  scenario "Module level dsl method that returns the default OpenStruct" do
    Flippant.dsl_method :person 
    person.should be_a_kind_of OpenStruct 
  end

  scenario "Class level dsl method that returns the default OpenStruct" do
    Person.dsl_method :dsl 
    instance = Person.dsl
    instance.should be_a_kind_of OpenStruct 
  end
end
