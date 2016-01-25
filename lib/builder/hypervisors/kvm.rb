require 'builder'

require 'zlib'
require 'archive/tar/minitar'

module Builder::Hypervisors
  class Kvm
    class << self
      def provision(name)
        node_dir = "#{config[:builder_root]}/#{name.to_s}"

        download_seed_image
        create_node_dir(node_dir)
      end

      private

      def config
        Builder.config
      end

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
    end
  end
end
