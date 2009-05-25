module FlexAttributes
  class DateConverter
      
    def self.convert(val=nil)
      
      if val.kind_of?(Date)
        return val
      else
        begin
          return Date.parse(val.to_s, true)
        rescue ArgumentError
          return nil
        end
      end
      
    end
      
  end
end