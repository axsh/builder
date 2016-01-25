require 'spec_helper'

describe "super_simple" do

  before(:all) do
    generate_builder_file(:with_one_dcmgr)
    generate_builder_config(:simple)
  end

  let(:builder) { Builder::Cli::Root.new }
  let(:dcmgr_node) { Builder::Nodes[:dcmgr] }

  it "creates one dcmgr node" do
    Builder::Nodes.provision(:dcmgr)
    expect(Builder::Nodes.ssh_to(:dcmgr)).to eq true
  end
end
