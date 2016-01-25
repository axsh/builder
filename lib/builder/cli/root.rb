require 'yaml'

module Builder::Cli
  class Root < Thor

    def initialize(*args)
      super(*args)
      Builder.recipe = YAML.load_file("builder.yml").symbolize_keys
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
    }
  end
end
