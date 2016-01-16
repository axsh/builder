
def sample_builder_yml
"
---
nodes: []
"
end

def generate_sample_builder_file
  File.open("builder.yml", "w") do |f|
    f.write sample_builder_yml
  end
end

def builder_pry
  FakeFS.deactivate!
  binding.pry
  FakeFS.activate!
end
