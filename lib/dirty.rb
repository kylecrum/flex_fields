module FlexAttributes
  module Dirty
    
    def self.included(base)
    
      ['_changed?', '_change', '_will_change!', '_was'].each do |suffix|
        base.flex_attributes_config.keys.each do |flex_attr|
          method_name = "#{flex_attr}#{suffix}"
          define_method(method_name.to_sym) {send("flex_attribute#{suffix}".to_sym,flex_attr)}
        end
      end
      
    end
    
    def write_flex_attribute(attribute, val)
      old_val = clone_attribute_value(:read_flex_attribute, attribute)
      converted_val = super(attribute,val)
      mark_flex_attribute_dirty(attribute,converted_val,old_val)
      return converted_val
    end
    
    def mark_flex_attribute_dirty(attribute,new_val,old_val)
      attribute = attribute.to_s
      
      # The attribute already has an unsaved change.
      if dirty_flex_attributes.include?(attribute)
        old_val = dirty_flex_attributes[attribute]
        dirty_flex_attributes.delete(attribute) if old_val == new_val 
      else
        dirty_flex_attributes[attribute] = old_val if old_val != new_val
      end

    end
  
    def dirty_flex_attributes
      @dirty_flex_attributes ||= {}
    end
    
    def changed?
      super || !dirty_flex_attributes.empty?
    end

    def changed
      super | dirty_flex_attributes.keys
    end

    def changes
      super.merge(dirty_flex_attributes.keys.inject({}) { |h, attr| h[attr] = flex_attribute_change(attr); h })
    end
    
    def save(*args)
      status = super(*args)
      dirty_flex_attributes.clear if status
      status
    end
    
    def save!(*args)
      status = super(*args)
      dirty_flex_attributes.clear
      status
    end
    
    def reload(*args)
      record = super(*args)
      dirty_flex_attributes.clear
      record
    end
    
    def attribute_change(attr)
      if self.class.flex_attributes_config.include?(attr.to_sym)
        flex_attribute_change(attr)
      else
        super(attr)
      end
    end
    
    private
    
      def changed_attributes
        changed_attributes_with_flex_column = super
        changed_attributes_with_flex_column.delete(flex_attribute_column.to_s)
        changed_attributes_with_flex_column
      end
    
      def flex_attribute_changed?(attr)
        dirty_flex_attributes.include?(attr.to_s)
      end
      
      def flex_attribute_change(attr)
        [dirty_flex_attributes[attr.to_s], read_flex_attribute(attr.to_sym)] if dirty_flex_attributes.include?(attr.to_s)
      end
      
      def flex_attribute_will_change!(attr)
        value = clone_attribute_value(:read_flex_attribute, attr.to_sym)
        dirty_flex_attributes[attr.to_s] = value
      end
      
      def flex_attribute_was(attr)
        flex_attribute_changed?(attr) ? dirty_flex_attributes[attr.to_s] : read_flex_attribute(attr.to_sym)
      end
    
  end
end