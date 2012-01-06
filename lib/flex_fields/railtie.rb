module FlexFields
  if defined? Rails::Railtie
    class Railtie < Rails::Railtie
      initializer 'flex_fields.insert_into_active_record' do
        ActiveSupport.on_load :active_record do
          ActiveRecord::Base.send :include, FlexFields::Base
        end
      end
    end
  end
end