require 'builder'

require 'zlib'
require 'archive/tar/minitar'

module Builder::Hypervisors
  class Kvm
    class << self
      include Builder::Helpers::Config
      include Builder::Helpers::Logger

      def provision(name)
        Builder::Networks.provision

        node_dir = "#{config[:builder_root]}/#{name.to_s}"
        node_image_path = "#{node_dir}/#{name.to_s}.raw"
        nics = node_spec(name)[:nics]
        disk_size = node_spec(name)[:disk]

        create_node_dir(node_dir)
        download_seed_image
        extract_seed_image(node_dir, node_image_path)
        expand_disk_size(node_image_path, disk_size)
        create_nics(nics, node_dir, node_image_path)
        create_runscript(name, node_dir, node_spec(name))

        launch(name)
      end

      private

      def launch(name)
        info "launch #{name}"
        system("cd #{config[:builder_root]}/#{name.to_s}; #{sudo} ./run.sh")
      end

      def sudo
        `whoami` =~ /root/ ? '' : 'sudo'
      end

      def download_seed_image

        info "download_seed_image"

        if File.exist?(config[:seed_image_path])
          info "skip seed image download. already existed"
        else
          system("curl -L #{config[:seed_image_url]} -o #{config[:seed_image_path]}")
          info "seed image downloaded : #{config[:seed_image_path]}"
        end
      end

      def create_node_dir(node_dir)

        info "create node dir"

        if not Dir.exist?(node_dir)
          system("mkdir -p #{node_dir}")
          info "directory created : #{node_dir}"
        else
          info "directory already existed : #{node_dir}"
        end
      end

      def extract_seed_image(node_dir, node_image_path)
        info "extract seed image"

        Zlib::GzipReader.open(config[:seed_image_path]) do |gz|
          Archive::Tar::Minitar::unpack(gz, node_dir)
        end

        raw_file = Dir.entries(node_dir).select {|f| /\.raw/ =~ f }.first
        system("mv #{node_dir}/#{raw_file} #{node_image_path}")

        info "seed image extracted to : #{node_image_path}"
      end

      def expand_disk_size(node_image_path, disk_size)
        info "expand disk size"

        system("qemu-img resize #{node_image_path} +#{disk_size}")

        info "image resized upto #{disk_size}"

        system("parted --script -- #{node_image_path} rm 2")
        system("parted --script -- #{node_image_path} rm 1")
        system("parted --script -- #{node_image_path} mkpart primary ext4 63s 100%")

        info "created new partitions"
      end

      def create_nics(nics, node_dir, node_image_path)
        info "create nics"

        mnt = "#{node_dir}/mnt"
        if not Dir.exist?(mnt)
          system("mkdir -p #{mnt}")
        end

        system("#{sudo} mount -o loop,offset=32256 #{node_image_path} #{mnt}")
        info "mount image"

        nics.keys.each do |eth|
          tmp_path = "#{node_dir}/ifcfg-#{eth}"
          nic_path = "#{mnt}/etc/sysconfig/network-scripts"

          File.open(tmp_path, "w") do |f|
            f.puts "DEVICE=#{eth}"
            f.puts "TYPE=Ethernet"
            f.puts "ONBOOT=yes"
            f.puts "BOOTPROTO=#{nics[eth][:bootproto]}"
            f.puts "IPADDR=#{nics[eth][:ip]}" if nics[eth][:ip]
            f.puts "PREFIX=#{nics[eth][:prefix]}" if nics[eth][:prefix]

            f.puts "DEFROUTE=#{nics[eth][:defroute]}" if nics[eth][:defroute]
          end

          if system("#{sudo} mv #{tmp_path} #{nic_path}")
            info "nic created : #{nic_path}/ifcfg-#{eth}"
          else
            error "mv failed : #{tmp_path}"
          end
        end

        system("#{sudo} umount #{mnt}")
        info "umount image"
      end

      def create_runscript(name, node_dir, spec)
        info "create runscript"

        qemu_kvm = if File.exist?("/usr/libexec/qemu-kvm")
                     "/usr/libexec/qemu-kvm"
                   elsif File.exist?("/usr/bin/qemu-kvm")
                     "/usr/bin/qemu-kvm"
                   else
                     nil
                   end
        info "qemu found in : #{qemu_kvm}"

        return if qemu_kvm.nil?

        port = Random.rand(10..99)

        File.open("#{node_dir}/run.sh", "w") do |f|
          f.puts "#!/bin/bash"
          f.puts "#{qemu_kvm} -name #{name} -cpu qemu64,+vmx,+svm -m #{spec[:memory]} \\"
          f.puts "-smp 1 -vnc 127.0.0.1:110#{port} -k en-us -rtc base=utc \\"
          f.puts "-monitor telnet:127.0.0.1:140#{port},server,nowait \\"
          f.puts "-serial telnet:127.0.0.1:150#{port},server,nowait \\"
          f.puts "-serial file:console.log \\"
          f.puts "-drive file=./#{name}.raw,media=disk,boot=on,index=0,cache=none,if=virtio \\"

          i = 0
          spec[:nics].keys.each do |eth|
            f.puts "-netdev tap,ifname=#{name}-#{i},id=hostnet#{i},script=,downscript= \\"
            f.puts "-device virtio-net-pci,netdev=hostnet#{i},mac=#{spec[:nics][eth][:mac_address]},bus=pci.0,addr=0x#{i+3} \\"
            i = i + 1
          end

          f.puts "-pidfile kvm.pid -daemonize"

          i = 0
          spec[:nics].keys.each do |eth|
            network = network_spec(spec[:nics][eth][:network].to_sym)
            cmd = bridge_cmd(network[:bridge_type])
            addif = bridge_addif_cmd(network[:bridge_type])
            bridge = network[:bridge_name]
            port = "#{name}-#{i}"

            f.puts "#{cmd} #{addif} #{bridge} #{port}"
            f.puts "ip link set #{port} up"
            i = i + 1
          end
        end
        info "runscript created"

        system("#{sudo} chmod +x #{node_dir}/run.sh")
      end
    end
  end
end
