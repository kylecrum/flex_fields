module FlexAttributes
  class HashConverter
      
    def self.convert(val=nil)
      if val.kind_of?(Hash)
        return val
      else
        return nil
      end
    end
      
  end
end