def simple
"
---
builder_root:
seed_image_url: 'https://www.dropbox.com/s/dyg2nkeeg07uu0a/centos-6.7-minimum.tar.gz?dl=0'
seed_image_path: 
"
end


def generate_builder_config(name)
  file_name = "#{Dir.pwd}/.builder"

  File.open(file_name, "w") do |f|
    f.write send(name)
  end
end
