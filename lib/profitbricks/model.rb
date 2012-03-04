module Profitbricks
	class Model
    @@associations = {}

    def initialize(hash = {})
      klass = self.class.to_s.underscore
      hash.keys.each do |k|
        attribute = k.to_s.sub("#{klass}_", '').to_sym
        if @@associations[attribute]
          initialize_association(attribute, @@associations[attribute], hash[k])
        else
          initialize_getter(attribute, type_cast(hash[k]))
        end
        
      end
    end

    def self.has_many(model)
      klass = Profitbricks.get_class model[0..-2].camelcase
      @@associations[model] = {:type => :collection, :class => klass}
      define_method(model) { instance_variable_get("@#{model}") }
    end

    def self.belongs_to(model)
      klass = Profitbricks.get_class model.to_s.camelcase
      @@associations[model] = {:type => :belongs_to, :class => klass}
      define_method(model) { instance_variable_get("@#{model}") }
    end

    private
    def type_cast(value)
      return value.to_i if value =~ /^\d+$/
      value
    end

    def initialize_getter name, value
      self.class.send :define_method, name do 
        instance_variable_get("@#{name}")
      end
      self.instance_variable_set("@#{name}", value)
    end

    def initialize_association name, association, value
      if association[:type] == :collection
        initialize_collection_association name, association, value
      elsif association[:type] == :belongs_to
        initialize_belongs_to_association name, association, value
      end
    end

    def initialize_collection_association name, association, value
      self.instance_variable_set("@#{name}", [])
      [value].flatten.each do |object|
        instance_variable_get("@#{name}").send(:push, association[:class].send(:new, object))
      end
    end

    def initialize_belongs_to_association name, association, value
      self.instance_variable_set("@#{name}", association[:class].send(:new, value))
    end

	end
end