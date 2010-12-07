require File.join(File.dirname(__FILE__), %w[.. spec_helper]) 

feature "Nested Flippant DSL" do
  scenario "that assigns a explicity named property" do 
    Person.dsl_method :name => :with do
      assign_property_method :name => :a_sibling, :property_name => :sibling, :maps_to => Person
    end
    p = Person.with do
      a_sibling :name => "Lucy"
    end
    p.sibling.should be_a_kind_of Person
    p.sibling.name.should == "Lucy"


  end
    
  scenario "that adds an item to a implicity named child collection" do
    Flippant.dsl_method :person, Person do
      add_item_method :name => :pet, :maps_to => Animal
    end
    p = person do
      pet "dog"
    end
    p.pets[0].species.should == "dog"
  end

  
  scenario "that adds an item to a explicity named child collection" do
    Flippant.dsl_method :person, Person do
      add_item_method :name => :has_pet, :collection_name => :pets, :maps_to => Animal
    end
    p = person do
      has_pet "dog"
    end
    p.pets[0].species.should == "dog"
  end
end
