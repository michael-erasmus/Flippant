require 'rubygems'
require 'active_support/inflector'
require 'ostruct'
require_relative './minter.rb'

module Flippant
  class DslMethod
    attr_reader :name

    def initialize(*args, &dsl_code)
      if args[0].is_a? Hash
        @name, klass= args[0].delete(:name), args[0].delete(:maps_to)
      else
       @name, klass= args[0], args[1] || OpenStruct 
      end
      instance_code = lambda{|*args|return klass.new(*args)}
      @minter = Minter.new instance_code 
      instance_eval(&dsl_code) if block_given?
    end

    def maps_to(&instance_code)
      @minter.instance_code = instance_code
    end

    def add_item_method(*args, &dsl_code)
      dsl = DslMethod.new(*args, &dsl_code) 
      collection_name = 
        if args[0].is_a?(Hash) and args[0].include?(:collection_name) 
          args[0].delete(:collection_name) 
        else
          dsl.name.to_s.pluralize
        end
      @minter.collection_methods[collection_name] = dsl   
      return dsl
    end

    def assign_property_method(*args, &dsl_code)
      dsl = DslMethod.new(*args, &dsl_code)
      property_name = args[0].delete(:property_name) 
      @minter.assign_property_methods[property_name] = dsl
      return dsl
    end

    def new_instance(*args, &instance_code)
      @minter.instance(*args, &instance_code)
    end
  end
  
  def self.dsl_method(*args, &dsl_code)
    dsl = DslMethod.new(*args, &dsl_code)
    
    dsl.methods << define_method(dsl.name) do |*instance_args,&instance_code| 
      dsl.new_instance(*instance_args, &instance_code) 
    end
    return dsl
  end

  Object.send(:define_method, "dsl_method") do |*args, &dsl_code|
    if args[0].is_a?(Hash)
      args[0][:maps_to] = self if args[0][:maps_to].nil?
    else
      args.insert(1, self) unless args[0].is_a?(Class)
    end
    dsl = DslMethod.new(*args, &dsl_code)
    
    dsl.methods << Object.send(:define_method, dsl.name) do |*instance_args,&instance_code| 
      dsl.new_instance(*instance_args, &instance_code) 
    end
    return dsl
  end
end
