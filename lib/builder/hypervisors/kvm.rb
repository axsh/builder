require 'builder'

module Builder::Hypervisors
  class Kvm
    class << self
      def provision(name)
        seed       = "#{config[:builder_root]}/seed"
        download_seed_image(seed)
      end

      private

      def config
        Builder.config
      end

      def download_seed_image(seed)
        if not File.exist?(seed)
          system("curl -L #{config[:seed_image_url]} -o #{seed}")
        end
      end
    end
  end
end
