
def sample_builder_yml
"
---
nodes:
  bare-metal:
    name: "bare-metal"
    ssh:
      from: "none"
      ip: "172.16.64.10"
      user: "bare-metal-user"
      key: "/path/to/private_key"

  dcmgr:
    name: "dcmgr"
    provision: 
      spec:
        os: "centos6.7"
        disk: 30
        memory: 4000
        nics:
          eth0:
            bootproto: "static"
            defroute: true
            ip: "192.168.100.2"
            prefix: 24
          eth1:
            bootproto: "none"
      provisioner: "shell"
      data:
        - "script1"
        - "script2"
    ssh:
      from: "bare-metal"
      ip: "192.168.100.2"
      user: "root"
      key: "/path/to/private_key"
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
