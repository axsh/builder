require_relative 'spec_helper'

describe "with_network" do
  before(:all) do
    generate_builder_file(:with_one_network, false)
    generate_builder_config(:simple, false)
    Builder::Cli::Root.new
  end

  after(:all) do
    Builder.recipe[:networks].each do |k, v|
      cmd = v[:bridge_type] == 'ovs' ? 'ovs-vsctl del-br' : 'brctl delbr'
      sudo = `whoami` =~ /root/ ? '' : 'sudo'
      system("#{sudo} ip link set #{v[:bridge_name]} down")
      system("#{sudo} #{cmd} #{v[:bridge_name]}")
    end

    system("kill -9 `cat #{Builder.config[:builder_root]}/dcmgr/kvm.pid`")

    FileUtils.rm_rf("#{Builder.config[:builder_root]}/dcmgr")
  end

  let(:name) { :dcmgr }
  let(:config) { Builder.config }

  let(:nodes) { Builder.recipe[:nodes] }
  let(:networks) { Builder.recipe[:networks] }

  it "creates one dcmgr node" do
    Builder::Networks.provision
    Builder::Nodes.provision(name)

    networks.each do |k, v|
      cmd = v[:bridge_type] == 'ovs' ? 'ovs-vsctl' : 'brctl'
      sudo = `whoami` =~ /root/ ? '' : 'sudo'
      expect(`#{sudo} #{cmd} show`).to include(v[:bridge_name])
    end

    expect(ping_to(nodes[name][:ssh][:ip])).to eq true
  end
end
