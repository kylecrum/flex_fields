module FlexFields
  module Base
  
    def self.included(base)
      base.extend(ClassMethods)
    end
  
    module ClassMethods
    
      def flex_fields(options={})
        
        set_flex_options(options)
        
        serialize(self.flex_fields_column, Hash) unless self.serialized_attributes.keys.include?(self.flex_fields_column)
      
        include InstanceMethods
        flex_accessor(options)
    
      end
      
      def set_flex_options(options)
        
        class_attribute :flex_fields_column unless self.respond_to?(:flex_fields_column) 
        class_attribute :flex_fields_config unless self.respond_to?(:flex_fields_config)
        
        self.flex_fields_config ||= {} 
        
        if !self.flex_fields_column
          column_name = options.delete(:column_name) || :flex
          self.flex_fields_column = column_name.to_sym if column_name
          self.flex_fields_config = options
        else
          self.flex_fields_config = flex_fields_config.merge(options)
        end
      end
    
      def flex_accessor(options)
        options.each_pair do |name,type|
          setter = (name.to_s + '=').to_sym
          define_method(name) {self.read_flex_field(name)}
          define_method(setter) {|val| self.write_flex_field(name, val)}
        end
      end
    
    end
  
    module InstanceMethods
    
      protected
      
        def type_for_flex_field(attribute)
          self.flex_fields_config[attribute]
        end

        def write_flex_field (attribute, val)
          attribute = attribute.to_sym
          converted_val = convert_to_type(val, type_for_flex_field(attribute))
          self[self.flex_fields_column][attribute] = converted_val
          send("#{flex_fields_column}_will_change!")
          return converted_val
        end

        def read_flex_field (attribute)
          attribute = attribute.to_sym
          converted_val = convert_to_type(self[self.flex_fields_column][attribute], type_for_flex_field(attribute))
          return converted_val 
        end

      private
    
        def convert_to_type(val, type)
          return val if val.kind_of?(type)
        
          begin
            converter_class = "FlexAttributes::#{type}Converter".constantize
          rescue #if no converter
            raise ArgumentError.new("Unsupported type #{type}")
          end
      
          return converter_class.convert(val)

        end
    
    end
  end
end