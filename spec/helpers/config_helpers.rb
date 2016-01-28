def generate_builder_config(name)
  file_name = "#{Dir.pwd}/.builder"

  FakeFS.deactivate!

  path = File.expand_path("../../sample_config/#{name.to_s}.yml", __FILE__)

  begin
    sample_yml = File.read(path)
  rescue => e
    Builder.logger.error e.message
    Builder.logger.error e.class
  end

  FakeFS.activate!
  File.open(file_name, "w") do |f|
    f.write sample_yml
  end
end
