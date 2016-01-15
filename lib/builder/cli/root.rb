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
      Builder.config = YAML.load_file(".builder")
    end
  end
end
