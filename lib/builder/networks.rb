require 'builder'
require 'aws-sdk'
require 'ipaddr'

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
          send("network_#{network[:network_type].to_s}", network)
        end
      end

      private

      def network_linux(network)
        if system("ip link show #{network[:bridge_name]}")
          info "#{network[:network_type]} already exists. skip creation"
        else
          cmd = send("#{network[:network_type].to_s}_addbr")
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

      def network_aws(n)
        ::Aws.config.update({
          region: config[:aws_region],
          credentials: ::Aws::Credentials.new(config[:aws_access_key], config[:aws_secret_key])
        })
        ec2 = ::Aws::EC2::Client.new

        v = recipe[:vpc_info]
        
        if v[:vpc_id]
          info "Skip vpc creation. already exist #{v[:vpc_id]}"
        else
          raise "InvalidParameter" if n[:prefix] < 8

          network_address = IPAddr.new("#{n[:ipv4_network]}/#{n[:prefix]-8}").to_s
          prefix = n[:prefix] - 8

          v[:vpc_id] = ec2.create_vpc(
              cidr_block: "#{network_address}/#{prefix}",
              instance_tenancy: "default").vpc.vpc_id

          info "Create VPC #{v[:vpc_id]}"
        end


        if n[:subnet_id]
          info "Skip subnet creation. already exist #{n[:subnet_id]}"
        else
          n[:subnet_id] = ec2.create_subnet(
            vpc_id: v[:vpc_id],
            cidr_block: "#{n[:ipv4_network]}/#{n[:prefix]}").subnet.subnet_id

          info "Create subnet #{n[:subnet_id]}"
        end

        if v[:route_table_id]
          info "Skip route_table creation. already exist #{v[:route_table_id]}"
        else
          v[:route_table_id] = ec2.describe_route_tables(
            filters: [
              { name: "vpc-id", values: [v[:vpc_id]] }
            ]
          ).route_tables.first.route_table_id

          info "Create route table #{v[:route_table_id]}"

          v[:association_id] = ec2.associate_route_table({
            subnet_id: n[:subnet_id],
            route_table_id: v[:route_table_id]
          }).association_id
        end


        if v[:igw_id]
          info "Skip igw creation. already exist #{v[:igw_id]}"
        else
          v[:igw_id] = ec2.create_internet_gateway.internet_gateway.internet_gateway_id

          ec2.attach_internet_gateway({
            internet_gateway_id: v[:igw_id],
            vpc_id: v[:vpc_id]
          })

          ec2.create_route({
            route_table_id: v[:route_table_id],
            destination_cidr_block: '0.0.0.0/0',
            gateway_id: v[:igw_id]
          })

          info "Create igw #{v[:igw_id]}"
        end


        if v[:secg_id]
          info "Skip secg creation. already exist #{v[:secg_id]}"
        else
          v[:secg_id] = ec2.create_security_group({
            group_name: v[:name],
            description: v[:name],
            vpc_id: v[:vpc_id]
          }).group_id

          secg = ::Aws::EC2::SecurityGroup.new(id: v[:secg_id])

          if secg.data.ip_permissions.empty?
            secg.authorize_ingress(ip_permissions: [{ip_protocol: "-1", from_port: nil, to_port: nil, user_id_group_pairs: [{group_id: "#{v[:secg_id]}"}]}])

            config[:global_cidrs].each do |global_cidr|
              secg.authorize_ingress(ip_permissions: [{ip_protocol: "-1", from_port: nil, to_port: nil, ip_ranges: [{cidr_ip: "#{global_cidr}"}]}])
              secg.authorize_egress(ip_permissions: [{ip_protocol: "-1", from_port: nil, to_port: nil, ip_ranges: [{cidr_ip: "#{global_cidr}"}]}])
            end
          end
          secg.load
          info "Create secg #{v[:secg_id]}"
        end
      end

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
