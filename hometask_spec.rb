module MyClass
  module InstanceMethods
    def class
      @parent_class
    end

    def kind_of?(other_class)
      self.class == other_class
    end
  end

  module ClassMethods
    def new(*args)
      Object.new.tap do |instance|
        instance.instance_variable_set('@parent_class', self)
        instance.singleton_class.prepend(InstanceMethods)
        instance.singleton_class.prepend(@instance_module)
        instance.send(:initialize, *args)
      end
    end

    def class
      @parent_class
    end
  end

  def self.new(&block)
    instance_module = Module.new.tap { |m| m.module_eval(&block) if block }
    Object.new.tap do |klass|
      klass.instance_variable_set(:@parent_class, self)
      klass.instance_variable_set('@instance_module', instance_module)
      klass.singleton_class.prepend(ClassMethods)
    end
  end
end

RSpec.describe Class do
  shared_examples_for 'class implementation' do
    let(:klass) do
      klass_class.new do
        def initialize(name)
          @name = name
        end

        def hello
          puts "Hello #{@name}"
        end
      end
    end
    let(:instance) { klass.new('John') }

    it { expect(klass.class).to eq klass_class }
    it { expect(instance.class).to eq klass }
    it { expect(instance.class).not_to eq klass_class.new }

    it { expect(instance).to be_a(klass) }
    it { expect(instance).not_to be_a(String) }

    it { expect { instance.hello }.to output("Hello John\n").to_stdout }

    it 'has isolated instances' do
      another_instance = klass.new('Fred')
      expect { instance.hello }.to output("Hello John\n").to_stdout
      expect { another_instance.hello }.to output("Hello Fred\n").to_stdout
    end
  end

  context 'with typical class implementation' do
    let(:klass_class) { Class }

    it_behaves_like 'class implementation'
  end

  context 'with own implementation' do
    let(:klass_class) { MyClass }

    it_behaves_like 'class implementation'
  end
end
