require_relative 'spec_helper'

describe "with_network" do
  before(:all) do
    generate_builder_file(:with_one_network, false)
    generate_builder_config(:simple, false)
  end

  after(:all) do
    sudo = `whoami` =~ /root/ ? '' : 'sudo'

    Builder.recipe[:networks].each do |k, v|
      cmd = v[:network_type] == 'ovs' ? 'ovs-vsctl del-br' : 'brctl delbr'
      system("#{sudo} ip link set #{v[:bridge_name]} down")
      system("#{sudo} #{cmd} #{v[:bridge_name]}")

      if v[:masquerade]
        system("#{sudo} iptables -t nat -D POSTROUTING -s #{v[:ipv4_network]}/#{v[:prefix]} -j MASQUERADE")
      end
    end

    system("#{sudo} kill -9 `#{sudo} cat #{Builder.config[:builder_root]}/dcmgr/kvm.pid`")

    FileUtils.rm_rf("#{Builder.config[:builder_root]}/dcmgr")
  end

  subject { Builder::Cli::Root.new }

  let(:name) { :dcmgr }
  let(:config) { Builder.config }

  let(:nodes) { Builder.recipe[:nodes] }
  let(:networks) { Builder.recipe[:networks] }

  it "creates one dcmgr node" do
    subject.invoke(:exec)

    networks.each do |k, v|
      cmd = v[:network_type] == 'ovs' ? 'ovs-vsctl' : 'brctl'
      sudo = `whoami` =~ /root/ ? '' : 'sudo'
      expect(`#{sudo} #{cmd} show`).to include(v[:bridge_name])
    end

    expect(ping_to(nodes[name][:ssh][:ip])).to eq true
  end
end
