class Minter 
  attr_accessor :instance_code
  attr_accessor :collection_methods
  attr_accessor :assign_property_methods  

  def initialize(instance_code)
    @instance_code = instance_code 
    @collection_methods = {}
    @assign_property_methods = {}
  end

  def instance(*args, &instance_code)
      properties = args.last.instance_of?(Hash) ? args.pop : {}
    
      instance = @instance_code.call(*args)
      mint_collection_methods(instance)
      mint_assign_property_methods(instance)
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
  def mint_collection_methods(instance)
    @collection_methods.each_pair do |collection_name, method|
      unless instance.methods.include? collection_name
        (class << instance; self; end).instance_eval do
            attr_accessor collection_name 
        end
      end
      (class << instance; self; end).instance_eval do
        define_method(method.name) do |*properties, &instance_code|
          item = method.new_instance(*properties, &instance_code)
          send("#{collection_name}=", []) if send(collection_name).nil?
          send(collection_name) << item
        end
      end
    end
  end
  def mint_assign_property_methods(instance)
    @assign_property_methods.each_pair do |property_name, method| 
      unless instance.methods.include? property_name
        (class << instance; self; end).instance_eval do
          attr_accessor property_name
        end
      end
      (class << instance; self; end).instance_eval do
        define_method(method.name) do |*properties, &instance_code|
          item = method.new_instance(*properties, &instance_code)
          send("#{property_name}=", item) 
          return item
        end
      end
    end
  end
end

