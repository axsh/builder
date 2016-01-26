require 'spec_helper'

describe "super_simple" do

  before(:all) do
    generate_builder_file(:with_one_dcmgr)
    generate_builder_config(:simple)
    Builder::Cli::Root.new
  end

  it "creates one dcmgr node" do
    Builder::Nodes.provision(:dcmgr)
    expect(Builder::Nodes.ssh_to(:dcmgr)).to eq true
  end
end
