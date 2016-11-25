module MyClass
  module CommonInstanceMethods
    def class
      @parent_class
    end

    def kind_of?(other)
      self.class == other
    end
  end

  module ClassMethods
    def class
      @parent_class
    end

    def new(*args)
      Object.new.tap do |instance|
        instance.instance_variable_set('@parent_class', self)
        instance.singleton_class.prepend(CommonInstanceMethods)
        instance.singleton_class.prepend(@instance_module)
        instance.send(:initialize, *args)
      end
    end
  end

  def self.new(&block)
    instance_module = Module.new.tap { |m| m.module_eval(&block) if block }
    Object.new.tap do |klass|
      klass.instance_variable_set('@parent_class', self)
      klass.instance_variable_set('@instance_module', instance_module)
      klass.singleton_class.prepend(ClassMethods)
    end
  end
end
