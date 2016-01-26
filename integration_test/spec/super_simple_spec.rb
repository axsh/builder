require_relative 'spec_helper'

describe "super_simple" do

  before(:all) do
    generate_builder_file(:with_one_dcmgr)
    generate_builder_config(:simple)
    Builder::Cli::Root.new
  end

  # after do
  #   FileUtils.rm_rf(config[:builder_root])
  # end

  let(:name) { :dcmgr }
  let(:config) { Builder.config }

  it "creates one dcmgr node" do
    Builder::Nodes.provision(name)

    expect(File.exist?("#{config[:builder_root]}/#{name.to_s}/#{name.to_s}.raw")).to eq true
  end
end
