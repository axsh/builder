
require 'thor'

module Builder

  class << self
    attr_accessor :config
  end

  module Cli
    autoload :Root, 'builder/cli/root'
  end
end
