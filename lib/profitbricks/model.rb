module Profitbricks
	class Model
    @@associations = {}

    def initialize(hash = {}, parent=nil)
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

    def reload
      updated = self.class.find(:id => self.id)
      update_attributes(updated)
    end

    def self.has_many(model, options = {})
      klass = Profitbricks.get_class model.to_s[0..-2], options
      @@associations[model] = {:type => :collection, :class => klass}
      define_method(model) { instance_variable_get("@#{model}") }
    end

    def self.belongs_to(model, options = {})
      klass = Profitbricks.get_class model.to_s, options
      @@associations[model] = {:type => :belongs_to, :class => klass}
      define_method(model) { instance_variable_get("@#{model}") }
    end

    def get_xml_and_update_attributes(hash, attributes=nil)
      attributes = hash.keys if attributes.nil?
      attributes.each do |a|
        initialize_getter(a, hash[a]) if hash[a]
      end
      hash, attributes = self.class.expand_attributes(hash, attributes, self.class)
      xml = self.class.build_xml(hash, attributes)
    end

    def self.get_xml_and_update_attributes(hash, attributes=[])
      hash, attributes = expand_attributes(hash, attributes, name())
      self.build_xml(hash, attributes)
    end

    def attributes
      a = {}
      self.instance_variables.each do |variable|
        a[variable.to_s[1..-1].to_sym] = self.instance_variable_get(variable)
      end
      a
    end

    private
    def update_attributes(updated)
      self.instance_variables.each do |var|
        self.instance_variable_set(var, updated.instance_variable_get(var))
      end
      true
    end

    def type_cast(value)
      return value.to_i if value =~ /^\d+$/
      value
    end

    def self.build_xml(hash ,attributes)
      attributes.collect do |a|
        "<#{a.to_s.lower_camelcase}>#{hash[a]}</#{a.to_s.lower_camelcase}>" if hash[a]
      end.join('')
    end

    def initialize_getter name, value=nil
      self.class.send :define_method, name do 
        instance_variable_get("@#{name}")
      end
      self.instance_variable_set("@#{name}", value) if value != nil
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
      [value].flatten.compact.each do |object|
        instance_variable_get("@#{name}").send(:push, association[:class].send(:new, object, self))
      end
    end

    def initialize_belongs_to_association name, association, value
      self.instance_variable_set("@#{name}", association[:class].send(:new, value, self))
    end

    def self.expand_attributes(hash, attributes, klass=nil)
      [:name, :algorithm].each do |a|
        deleted =  hash.delete(a)
        if deleted
          hash["#{klass.to_s.underscore}_#{a.to_s}"] = deleted
          attributes.delete(a)
          attributes.push "#{klass.to_s.underscore}_#{a.to_s}"
        end
      end
      return hash, attributes
    end
	end
end