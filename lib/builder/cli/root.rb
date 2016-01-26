require 'yaml'

module Builder::Cli
  class Root < Thor
    include Builder::Helpers::Logger

    def initialize(*args)
      super(*args)
      Builder.recipe = YAML.load_file("builder.yml").symbolize_keys
      Builder.config = config_loader(YAML.load_file(".builder").symbolize_keys)
    end

    desc "init", "init"
    def init
      [".builder", "builder.yml"].each do |file|
        File.open(file,"w") if not File.exist?(file)
      end
    end

    desc "exec", "exec"
    def exec
    end

    no_tasks {
      def validate
        Builder.recipe[:validated] = true
      end

      def config_loader(c)
        c[:builder_root] ||= "#{File.expand_path("../../../../default_builder_dir", __FILE__)}"
        c[:seed_image_path] ||= "#{c[:builder_root]}/seed"

        if not Dir.exist?(c[:builder_root])
          FileUtils.mkdir_p(c[:builder_root])
          info "builder_root directory created : #{c[:builder_root]}"
        end

        c
      end
    }
  end
end
