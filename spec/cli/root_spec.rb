require 'spec_helper'

describe Builder::Cli::Root do

  before do
    generate_builder_file
    subject.load_conf
  end

  subject { Builder::Cli::Root.new }

  describe "init" do
    it "creates .builder and builder.yml file" do
      subject.invoke(:init)
      expect(File.exist?(".builder")).to eq true
      expect(File.exist?("builder.yml")).to eq true
    end
  end

  describe "load_conf" do
    it "loads builder conf files" do
      expect(Builder.recipe).not_to eq nil
    end
  end

  describe "ssh_to" do
    it "do something" do
    end
  end
end
