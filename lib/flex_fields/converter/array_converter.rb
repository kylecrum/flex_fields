module FlexAttributes
  class ArrayConverter
      
    def self.convert(val=nil)
      return [] if val.nil?
      if val.kind_of?(Array)
        return val
      else
        return [val]
      end
    end
    
  end
end