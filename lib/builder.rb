
require 'thor'
require 'yaml'

require_relative 'ext/hash'

module Builder

  class << self
    attr_accessor :recipe
    attr_accessor :config
  end

  module Cli
    autoload :Root, 'builder/cli/root'
  end

  module Hypervisors
    autoload :Kvm, 'builder/hypervisors/kvm'
  end

  autoload :Nodes, 'builder/nodes'
end
