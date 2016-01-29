require 'builder'
require 'aws-sdk'

module Builder::Hypervisors
  class Aws
    class << self
      include Builder::Helpers::Config
      include Builder::Helpers::Logger

      def provision(name)
        Builder::Network.provision

        ::Aws.config.update({
          region: config[:aws_region],
          credentials: ::Aws::Credentials.new(config[:aws_access_key], config[:aws_secret_key])
        })
        ec2 = ::Aws::EC2::Client.new

        node = node_spec(name)

        nics = []
        i = 0
        node[:nics].each do |k, v|
          nic = {}
          nic[:device_index] = 0
          nic[:subnet_id] = recipe[:networks][v[:network].to_sym][:subnet_id]
          nic[:groups] = [recipe[:vpc_info][:secg_id]]
          nic[:associate_public_ip_address] = true if node[:nics].size == 1
          nics << nic
          i = i + 1
        end
        
        node[:instance_id] = ec2.run_instances({
          image_id: node[:image_id],
          min_count: 1,
          max_count: 1,
          key_name: node[:key_pair],
          instance_type: node[:instance_type],
          network_interfaces: nics
        }).instances.first.instance_id
        i = ::Aws::EC2::Instance.new(id: node[:instance_id])
        info "Create instance #{node[:instance_id]}"
        i.wait_until_running

        recipe_save
        config_save
      end

    end
  end
end
