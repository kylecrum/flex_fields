require 'flex_fields/version'
require 'flex_fields/base'
require 'flex_fields/railtie'
# Load Converters
Dir.entries("#{File.dirname(__FILE__)}/flex_fields/converter").each do |filename|
  require "flex_fields/converter/#{filename.gsub('.rb', '')}" if filename =~ /\.rb$/
end