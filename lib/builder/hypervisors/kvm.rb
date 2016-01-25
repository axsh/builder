require 'builder'

module Builder::Hypervisors
  class Kvm
    class << self
      def provision(name)
        true
      end
    end
  end
end
