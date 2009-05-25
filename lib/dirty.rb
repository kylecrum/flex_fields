module FlexAttributes
  module Dirty
    
    def self.included(base)
      base.alias_method_chain :changed,                    :flex_attributes
      base.alias_method_chain :save,                       :flex_attributes
      base.alias_method_chain :save!,                      :flex_attributes
      base.alias_method_chain :reload,                     :flex_attributes
      base.alias_method_chain :write_flex_attribute,       :dirty
      base.alias_method_chain :attribute_change,           :flex_attributes

      ActiveRecord::Dirty::DIRTY_SUFFIXES.each do |suffix|
        base.flex_attributes_config.keys.each do |flex_attr|
          method_name = "#{flex_attr}#{suffix}"
          define_method(method_name.to_sym) {send("flex_attribute#{suffix}".to_sym,flex_attr)}
        end
      end
      
    end
    
    def write_flex_attribute_with_dirty (attribute, val)
      old_val = clone_attribute_value(:read_flex_attribute, attribute)
      converted_val = write_flex_attribute_without_dirty(attribute,val)
      mark_flex_attribute_dirty(attribute,converted_val,old_val)
      return converted_val
    end
    
    def mark_flex_attribute_dirty(attribute,new_val,old_val)
      attribute = attribute.to_s
      
      # The attribute already has an unsaved change.
      if dirty_flex_attributes.include?(attribute)
        old_val = dirty_flex_attributes[attribute]
        dirty_flex_attributes.delete(attribute) unless old_val == new_val 
      else
        dirty_flex_attributes[attribute] = old_val if old_val != new_val
      end

    end
  
    def dirty_flex_attributes
      @dirty_flex_attributes ||= {}
    end
    
    def save_with_flex_attributes(*args)
      status = save_without_flex_attributes(*args)
      dirty_flex_attributes.clear if status
      status
    end
    
    def save_with_flex_attributes!(*args)
      status = save_without_flex_attributes!(*args)
      dirty_flex_attributes.clear
      status
    end
    
    def reload_with_flex_attributes(*args)
      record = reload_without_flex_attributes(*args)
      dirty_flex_attributes.clear
      record
    end
    
    private 
    
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
    
      def attribute_change_with_flex_attributes(attr)
        if self.class.flex_attributes_config.include?(attr.to_sym)
          flex_attribute_change(attr)
        else
          attribute_change_without_flex_attributes(attr)
        end
      end
    
      def changed_with_flex_attributes
        changed_without = changed_without_flex_attributes
        changed_without.delete(flex_attribute_column.to_s)
        changed_without + dirty_flex_attributes.keys
      end
    
  end
end