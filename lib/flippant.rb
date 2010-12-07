require 'rubygems'
require 'active_support/inflector'
require 'ostruct'

module Flippant
  class DslMethod
    attr_reader :name

    def initialize(*args, &dsl_code)
      if args[0].instance_of? Hash
        @name, klass = args[0].delete(:name), args[0].delete(:maps_to)
      else
       @name, klass = args[0], args[1] || OpenStruct 
      end
      @returns_instance = lambda{|*args|return klass.new(*args)}
      instance_eval(&dsl_code) if block_given?
    end

    def instance_class
      new_instance.class
    end

    def maps_to(&instance_code)
      @returns_instance = instance_code
    end

    def add_item_method(*args, &dsl_code)
      dsl = DslMethod.new(*args, &dsl_code) 
      collection_name = args[0].delete(:collection_name) || dsl.name.to_s.pluralize
      unless new_instance.respond_to? collection_name
        instance_class.class_eval{ attr_accessor collection_name}
      end
      instance_class.send(:define_method, dsl.name) do |*properties, &instance_code|
        item = dsl.new_instance(*properties, &instance_code)
        send("#{collection_name}=", []) if send(collection_name).nil?
        send(collection_name) << item
      end
      return dsl
    end

    def assign_property_method(*args, &dsl_code)
      dsl = DslMethod.new(*args, &dsl_code)
      property_name = args[0].delete(:property_name) 
      unless new_instance.respond_to? property_name
        instance_class.class_eval{ attr_accessor property_name}
      end
      instance_class.send(:define_method, dsl.name) do |*properties, &instance_code|
        item = dsl.new_instance(*properties, &instance_code)
        send("#{property_name}=", item) 
        item
      end
      return dsl
    end

    def new_instance(*args, &instance_code)
      properties = args.last.instance_of?(Hash) ? args.pop : {}
      instance = @returns_instance.call(*args)
      properties.each_pair do |k,v|
        instance.send("#{k.to_s}=",v)
      end  
      if block_given? && instance_code.arity == 1
        instance_code[instance]
      elsif block_given?
        instance.instance_eval(&instance_code) if block_given?   
      end 
      instance
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
