require 'builder'

require 'zlib'
require 'archive/tar/minitar'

module Builder::Hypervisors
  class Kvm
    class << self
      include Builder::Helpers::Config

      def provision(name)
        node_dir = "#{config[:builder_root]}/#{name.to_s}"
        node_image_path = "#{node_dir}/#{name.to_s}.raw"
        nics = node_spec(name)[:nics]

        download_seed_image
        create_node_dir(node_dir)
        extract_seed_image(node_image_path)
        expand_disk_size(node_image_path)
      end

      private

      def download_seed_image
        if not File.exist?(config[:seed_image_path])
          system("curl -L #{config[:seed_image_url]} -o #{config[:seed_image_path]}")
        end
      end

      def create_node_dir(node_dir)
        if not Dir.exist?(node_dir)
          system("mkdir -p #{node_dir}")
        end
      end

      def extract_seed_image(node_image_path)
        Zlib::GzipReader.open(config[:seed_image_path]) do |gz|
          Archive::Tar::Minitar::unpack(gz, node_image_path)
        end
      end

      def expand_disk_size(node_image_path, disk_size)
        system("qemu-img resize #{node_image_path} +#{disk_size}")

        system("parted --script -- #{node_image_path} rm 2")
        system("parted --script -- #{node_image_path} rm 1")
        system("parted --script -- #{node_image_path} mkpart primary ext4 63s 100%")
      end

      def create_nics(nics, node_dir, node_image_path)
        mnt = "#{node_dir}/mnt"
        if not Dir.exist?(mnt)
          system("mkdir -p #{mnt}")
        end

        system("mount -o loop,offset=32256 #{node_image_path} #{mnt}")

        nics.keys.each do |nic|
          File.open("#{mnt}/etc/sysconfig/network-scripts/ifcfg-#{nic}", "w") do |f|
          end
        end
      end
    end
  end
end
