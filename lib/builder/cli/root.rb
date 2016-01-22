require 'yaml'

module Builder::Cli
  class Root < Thor
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
        Builder.recipe['validated'] = true
      end

      def load_conf
        Builder.recipe = YAML.load_file("builder.yml")
      end
    }
  end
end
