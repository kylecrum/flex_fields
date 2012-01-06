module FlexAttributes
  class TimeConverter
      
    def self.convert(val=nil)
      if val.kind_of?(Time)
        return val
      else
        begin
          return Time.parse(val.to_s)
        rescue ArgumentError
          return nil
        end
      end
    end
      
  end
end