require 'spec_helper'

describe Builder::Nodes do
  before do
    generate_builder_file(:with_all)
  end

  describe "list_to_provision" do
    it "lists nodes to provision" do
      expect(Builder::Nodes.list_to_provision).to eq [:dcmgr]
    end
  end

  describe "provision" do

    before do
      allow(Builder::Hypervisors::Kvm).to receive(:provision).with(:dcmgr).and_return(true)
    end

    it "creates a dcmgr node" do
      expect(Builder::Nodes.provision(:dcmgr)).to eq true
    end
  end
end
