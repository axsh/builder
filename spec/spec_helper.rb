require 'rspec'
require 'fakefs/spec_helpers'
require 'builder'
require 'helpers/builder_spec_helpers'

RSpec.configure do |config|
  config.include FakeFS::SpecHelpers
  config.include Builder::SpecHelpers
  config.expose_dsl_globally = true
  config.color = true
  config.formatter = :documentation
end
