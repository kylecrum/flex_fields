module FlexAttributes
  class DateTimeConverter
      
    def self.convert(val=nil)
      if val.kind_of?(DateTime)
        return val
      else
        begin
          return DateTime.parse(val.to_s, true)
        rescue ArgumentError
          return nil
        end
      end
    end
      
  end
end