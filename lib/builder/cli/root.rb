require 'yaml'

module Builder::Cli
  class Root < Thor

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
        c[:builder_root] ||= "#{File.expand_path("../../../../", __FILE__)}"
        c[:seed_image_path] ||= "#{c[:builder_root]}/seed"
        c
      end
    }
  end
end
