require_relative 'spec_helper'

describe "super_simple" do

  before(:all) do
    generate_builder_file(:with_one_dcmgr)
    generate_builder_config(:simple)
    Builder::Cli::Root.new
  end

  after(:all) do
    FileUtils.rm_rf("#{Builder.config[:builder_root]}/dcmgr")
  end

  let(:name) { :dcmgr }
  let(:config) { Builder.config }

  it "creates one dcmgr node" do
    expect {
      Builder::Nodes.provision(name)
    }.not_to raise_error
  end
end
