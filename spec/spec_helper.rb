require 'rspec'
require 'fakefs/spec_helpers'
require 'builder'

RSpec.configure do |config|
  config.include FakeFS::SpecHelpers
  config.expose_dsl_globally = true
  config.color = true
  config.formatter = :documentation
end
