require 'builder'

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
        seed = "#{config[:builder_root]}/seed"
        if not File.exist?(seed)
          system("curl -L #{config[:seed_image_url]} -o #{seed}")
        end
      end

      def create_node_dir(node_dir)
        if not Dir.exist?(node_dir)
          system("mkdir -p #{node_dir}")
        end
      end
    end
  end
end
