require 'spec_helper'

describe Builder::Nodes do
  before do
    generate_builder_file
  end

  describe "list_to_provision" do
    it "lists nodes to provision" do
      expect(Builder::Nodes.list_to_provision).to eq [:dcmgr]
    end
  end
end
