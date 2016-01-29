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

          if system("ip link show #{network[:bridge_type]}")
            info "#{network[:bridge_type]} already exists. skip creation"
          else
            cmd = send("#{network[:bridge_type].to_s}_addbr")
            system("#{sudo} #{cmd} #{network[:bridge_name]}")
            system("#{sudo} ip link set #{network[:bridge_name]} up")

            if network[:ipv4_gateway]
              system("#{sudo} ip addr add #{network[:ipv4_gateway]}/#{network[:prefix]} dev #{network[:bridge_name]}")
            end

            if network[:masquerade]
              system("#{sudo} iptables -t nat -A POSTROUTING -s #{network[:ipv4_network]}/#{network[:prefix]} -j MASQUERADE")
            end

            info "bridge #{network[:bridge_name]} created"
          end
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
