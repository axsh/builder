require 'builder'

module Builder
  class Networks
    class << self
      include Builder::Helpers::Config
      include Builder::Helpers::Logger

      def provision(name = :all)
        if name == :all
          networks.keys.each {|n| provision(n) }
        else
          network = network_spec(name)
          cmd = send("#{network[:bridge_type].to_s}_addbr")
          system("#{sudo} #{cmd} #{network[:bridge_name]}")
          system("#{sudo} ip link set #{network[:bridge_name]} up")

          info "bridge #{network[:bridge_name]} created"
        end
      end

      private

      def sudo
        `whoami` =~ /root/ ? '' : 'sudo'
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
