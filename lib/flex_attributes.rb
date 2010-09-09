require 'dirty'

# Load Converters
Dir.entries("#{File.dirname(__FILE__)}/converter").each do |filename|
  require "converter/#{filename.gsub('.rb', '')}" if filename =~ /\.rb$/
end

module FlexAttributes
  
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    
    def flex_attributes(options={})
       
      track_flex_dirty = options.delete(:track_dirty)
      track_flex_dirty = false if track_flex_dirty.nil?
      
      unless super_flex_column = superclass.flex_attributes_column
        column_name = options.delete(:column_name) || :flex
        write_inheritable_attribute(:flex_attributes_column,column_name.to_sym)
      else
        write_inheritable_attribute(:flex_attributes_column,super_flex_column)
      end
      
      unless super_flex_config = superclass.flex_attributes_config
        write_inheritable_attribute(:flex_attributes_config,options)
      else
        write_inheritable_attribute(:flex_attributes_config,super_flex_config.merge(options))
      end
      
      options.each_pair do |name,type|
        setter = (name.to_s + '=').to_sym
        define_method(name) {self.read_flex_attribute(name)}
        define_method(setter) {|val| self.write_flex_attribute(name, val)}
      end
      
      before_update :init_flex_column
      serialize flex_attributes_column, Hash
      
      include InstanceMethods
      
      if track_flex_dirty && !included_modules.include?(Dirty)
        include Dirty
      end
    end
    
    def flex_attributes_column
      read_inheritable_attribute(:flex_attributes_column)
    end
    
    def flex_attributes_config
      read_inheritable_attribute(:flex_attributes_config)
    end
    
  end
  
  module InstanceMethods
    
    protected

      BASE64_TOKEN = "//BASE64//"
    
      #convenience method
      def flex_attribute_column
        self.class.flex_attributes_column
      end
      
      def type_for_flex_attribute(attribute)
        self.class.flex_attributes_config[attribute]
      end

      def write_flex_attribute (attribute, val)
        attribute = attribute.to_sym
        self[flex_attribute_column] = Hash.new unless self[flex_attribute_column].kind_of?(Hash)
        converted_val = convert_to_type(val, type_for_flex_attribute(attribute))
        self[flex_attribute_column][attribute] = encode_flex_attribute_value(converted_val)
        return converted_val
      end

      def read_flex_attribute (attribute)
        return nil unless self[flex_attribute_column].kind_of?(Hash)
        attribute = attribute.to_sym
        val = convert_to_type(self[flex_attribute_column][attribute], type_for_flex_attribute(attribute))
        return decode_flex_attribute_value(val) 
      end

    private
    
      #Encode and decode String values in case there are YAML reserved characters in the String
      
      def decode_flex_attribute_value(val)
        if val.kind_of?(String) && val.starts_with?(BASE64_TOKEN)
          return Base64.decode64(val[BASE64_TOKEN.length, val.length])
        else
          return val
        end
      end
    
      def encode_flex_attribute_value(val)
        if val.kind_of?(String) && !val.blank?
          return "#{BASE64_TOKEN}#{Base64.encode64(val)}"
        else
          return val
        end
      end

      def init_flex_column
        self[flex_attribute_column] = {} unless self[flex_attribute_column].kind_of?(Hash)
      end
    
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

ActiveRecord::Base.send :include, FlexAttributes