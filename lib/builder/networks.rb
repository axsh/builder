require 'builder'

module Builder
  class Networks
    class << self
      def provision(name = :all)
        if name == :all
          networks.keys.each {|n| provision(n) }
        else
          network = network_spec(name)
          cmd = send("#{network[:bridge_type].to_s}_addbr")
          system("#{sudo} #{cmd} #{network[:bridge_name]}")
          system("#{sudo} ifup #{network[:bridge_name]}")
        end
      end

      private

      def sudo
        `whoami` =~ /root/ ? '' : 'sudo'
      end
      def networks
        Builder.recipe[:networks]
      end

      def network_spec(name)
        networks[name]
      end

      def ovs_addbr
        "ovs-vsctl add-br"
      end

      def linux_addbr
        "brctl addbr"
      end
    end
  end
end
