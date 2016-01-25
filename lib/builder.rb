
require 'thor'
require 'yaml'

require_relative 'ext/hash'

module Builder

  class << self
    attr_accessor :recipe
  end

  module Cli
    autoload :Root, 'builder/cli/root'
  end
end
