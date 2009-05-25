ActiveRecord::Base.send :include, FlexAttributes
require 'dirty'

# Load Converters
Dir.entries("#{File.dirname(__FILE__)}/lib/converter").each do |filename|
  require "converter/#{filename.gsub('.rb', '')}" if filename =~ /\.rb$/
end