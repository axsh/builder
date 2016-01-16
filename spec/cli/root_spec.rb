require 'spec_helper'

describe Builder::Cli::Root do

  subject { Builder::Cli::Root.new }

  describe "init" do
    it "creates .builder and builder.yml file" do
      subject.invoke(:init)
      expect(File.exist?(".builder")).to eq true
      expect(File.exist?("builder.yml")).to eq true
    end
  end

  describe "exec" do

    before do
      generate_sample_builder_file
      subject.invoke(:exec)
    end

    it "loads builder.yml" do
      expect(Builder.recipe).to be_an_instance_of Hash
      expect(Builder.recipe['nodes']).to eq []
    end
  end
end
