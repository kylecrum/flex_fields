# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "flex_fields/version"

Gem::Specification.new do |s|
  s.name        = 'flex_fields'
  s.version     = FlexFields::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = [ 'Kyle Crum' ]
  s.email       = [ 'kyle.e.crum@gmail.com' ]
  s.homepage    = 'http://github.com/stouset/twitter_bootstrap_form_for'
  s.summary     = 'Rails form builder optimized for Twitter Bootstrap'
  s.description = 'A custom Rails FormBuilder that assumes the use of Twitter Bootstrap'

  s.files        = `git ls-files`.split("\n")
  s.test_files   = `git ls-files -- {test,spec}/*`.split("\n")
  s.executables  = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('activerecord', '>= 3.0')
  s.add_dependency('activesupport', '>= 3.0')
end