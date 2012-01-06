require 'rubygems'
require 'bundler/setup'
require 'sqlite3'

require 'flex_fields'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'active_record'
require 'active_support'

$:.unshift "#{File.dirname(__FILE__)}/../lib"
require 'flex_fields'

ActiveRecord::Base.configurations = {'sqlite3' => {:adapter => 'sqlite3', :database => ':memory:'}}
ActiveRecord::Base.establish_connection('sqlite3')
 
ActiveRecord::Schema.define(:version => 0) do
  create_table :some_models do |t|
    t.string :name
    t.string :type
    t.text   :flex
    t.text   :something
  end
end

ActiveRecord::Base.send(:include, FlexFields::Base)

def reset_classes
  Object.send(:remove_const, :SomeModel) rescue nil
  Object.send(:remove_const, :InheritedModel) rescue nil
  Object.const_set(:SomeModel, Class.new(ActiveRecord::Base))
  Object.const_set(:InheritedModel, SomeModel)
end
 
reset_classes