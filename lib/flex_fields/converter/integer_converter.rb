module FlexAttributes
  class IntegerConverter
      
    def self.convert(val=nil)
      val.nil? ? nil : val.to_i
    end
      
  end
end