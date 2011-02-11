class InstanceMaker

  attr_accessor :instance_code

  def initialize(instance_code)
    @instance_code = instance_code 
  end

  def instance(minter, *args, &instance_code)
      properties = args.last.instance_of?(Hash) ? args.pop : {}
    
      instance = @instance_code.call(*args)
      minter.mint(instance)
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
