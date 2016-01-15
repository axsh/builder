
module Builder
  module SpecHelpers
    def generate_sample_builder_file
      File.open(".builder", "w") do |f|
        f.write("---")
        f.write("nodes:")
      end
    end
  end
end
