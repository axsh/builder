
require 'thor'

module Builder

  class << self
    attr_accessor :recipe
  end

  module Cli
    autoload :Root, 'builder/cli/root'
  end
end
