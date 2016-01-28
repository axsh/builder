def generate_builder_file(name, fakefs = true)
  file_name = "#{Dir::pwd}/builder.yml"

  FakeFS.deactivate! if fakefs

  path = File.expand_path("../../sample_builder_yml/#{name.to_s}.yml", __FILE__)

  begin
    sample_yml = File.read(path)
  rescue => e
    Builder.logger.error e.message
    Builder.logger.error e.class
  end

  FakeFS.activate! if fakefs

  File.open(file_name, "w") do |f|
    f.write sample_yml
  end
end
