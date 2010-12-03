require 'rubygems'
require 'active_support/inflector'
require 'ostruct'

module Flippant
  class DslMethod
    attr_accessor :instance
    
    def initialize(&dsl_code)
      @returns_instance = lambda{return OpenStruct.new}
      instance_eval(&dsl_code) if block_given?
    end
    def instance_class
      new_instance.class
    end
    def maps_to(&instance_code)
      @returns_instance = instance_code
    end
    def add_item_method(name, &dsl_code)
      dsl = block_given? ? DslMethod.new(&dsl_code) : DslMethod.new
      collection_name = name.to_s.pluralize
      unless new_instance.respond_to? collection_name
        instance_class.class_eval{ attr_accessor name.to_s.pluralize.to_sym}
      end
      instance_class.send(:define_method, name) do |*properties, &instance_code|
        item = dsl.new_instance(*properties, &instance_code)
        send("#{collection_name}=", []) if send(collection_name).nil?
        send(collection_name) << item
      end
      return dsl
    end
    def new_instance(*properties, &instance_code)
      instance = @returns_instance.call
      properties[0].each_pair do |k,v|
        instance.send("#{k.to_s}=",v)
      end unless properties.length == 0 
      instance.instance_eval(&instance_code) if block_given?   
      instance
    end
  end
  
  def self.dsl_method(name,on=self, &dsl_code)
    dsl = DslMethod.new(&dsl_code)
    
    dsl.methods << on.send(:define_method, name) do |*properties,&instance_code| 
      dsl.new_instance(*properties, &instance_code) 
    end
    return dsl
  end
end
