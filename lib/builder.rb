
require 'thor'
require 'yaml'
require 'logger'

require_relative 'ext/hash'

module Builder

  class << self
    attr_accessor :logger
    attr_accessor :recipe
    attr_accessor :config
  end

  module Cli
    autoload :Root, 'builder/cli/root'
  end

  module Hypervisors
    autoload :Kvm, 'builder/hypervisors/kvm'
  end

  module Helpers
    autoload :Config, 'builder/helpers/config'
    autoload :Logger, 'builder/helpers/logger'
  end

  autoload :Nodes, 'builder/nodes'
end

Builder.logger ||= ::Logger.new(STDOUT)
