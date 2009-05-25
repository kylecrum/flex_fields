begin
  require File.dirname(__FILE__) + '/../../../../spec/spec_helper'
rescue LoadError
  puts "You need to install rspec in your base app"
  exit
end

ActiveRecord::Base.configurations = {'sqlite3' => {:adapter => 'sqlite3', :database => ':memory:'}}
ActiveRecord::Base.establish_connection('sqlite3')
 
ActiveRecord::Base.logger = Logger.new(STDERR)
ActiveRecord::Base.logger.level = Logger::WARN
 
ActiveRecord::Schema.define(:version => 0) do
  create_table :some_models do |t|
    t.string :name
  end
end
 
class SomeModel < ActiveRecord::Base
end

class AnotherModel < ActiveRecord::Base
end

class InheritedModel < SomeModel
end