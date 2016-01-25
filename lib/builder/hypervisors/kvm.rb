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
        create_nics(nics, node_dir, node_image_path)
        create_runscript(name, node_dir, node_spec(name))
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

        nics.keys.each do |eth|
          File.open("#{mnt}/etc/sysconfig/network-scripts/ifcfg-#{eth}", "w") do |f|
            f.puts "DEVICE=#{eth}"
            f.puts "TYPE=Ethernet"
            f.puts "ONBOOT=yes"
            f.puts "BOOTPROTO=#{nics[eth][:bootproto]}"
            f.puts "IPADDR=#{nics[eth][:ip]}" if nics[eth][:ip]
            f.puts "PREFIX=#{nics[eth][:prefix]}" if nics[eth][:prefix]

            f.puts "DEFROUTE=#{nics[eth][:defroute]}" if nics[eth][:defroute]
          end
        end

        system("umount #{mnt}")
      end

      def create_runscript(name, node_dir, spec)
        qemu_kvm = if File.exist?("/usr/libexec/qemu-kvm")
                     "/usr/libexec/qemu-kvm"
                   elsif File.exist?("/usr/bin/qemu-kvm")
                     "/usr/bin/qemu-kvm"
                   else
                     nil
                   end

        return if qemu_kvm.nil?

        port = Random.rand(10..99)

        File.open("#{node_dir}/run.sh", "w") do |f|
          f.puts "#!/bin/bash"
          f.puts "#{qemu_kvm} -name #{name} -cpu qemu64,+vmx,+svm -memory #{spec[:memory]} \\"
          f.puts "-smp 1 -vnc 127.0.0.1:110#{port} -k en-us -rtc base=utc \\"
          f.puts "-monitor telnet:127.0.0.1:140#{port},server,nowait \\"
          f.puts "-serial telnet:127.0.0.1:150#{port},server,nowait \\"
          f.puts "-serial file:console.log \\"
          f.puts "-drive file=./#{name}.raw,media=disk,boot=on,index=0,cache=none,if=virtio \\"

          i = 0
          spec[:nics].keys.each do |eth|
            f.puts "-netdev tap,ifname=#{name}-#{i},id=hostnet#{i},script=,downscript= \\"
            f.puts "-device virtio-net-pci,netdev=hostnet#{i},mac=#{spec[:nics][key][:mac_address]},bus=pci.0,addr=0x#{i+3} \\"
            i = i + 1
          end

          f.puts "-pidfile kvm.pid -daemonize -enable-kvm"
        end
      end
    end
  end
end
