
def with_all
'
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
        type: "kvm"
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
'
end

def with_one_dcmgr
'
---
nodes:
  dcmgr:
    name: "dcmgr"
    provision: 
      spec:
        type: "kvm"
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
      ip: "192.168.100.2"
      user: "root"
      key: "/path/to/private_key"
'
end

def generate_builder_file(name)
  file_name = "#{Dir::pwd}/builder.yml"

  File.open(file_name, "w") do |f|
    f.write send(name)
  end
end
