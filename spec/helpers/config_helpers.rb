def simple
"
---
builder_root: 
"
end


def generate_builder_config(name)
  file_name = "#{Dir.pwd}/.builder"

  File.open(file_name, "w") do |f|
    f.write send(name)
  end
end
