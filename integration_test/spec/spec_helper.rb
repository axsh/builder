require 'rspec'
require 'builder'
require 'pry'

Dir['./spec/helpers/*.rb'].map {|f| require f }

RSpec.configure do |config|
  config.expose_dsl_globally = true

  config.color = true
  config.formatter = :documentation

  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
end
