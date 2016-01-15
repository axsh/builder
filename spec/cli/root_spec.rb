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
    it "gives nothing" do
      expect(subject.invoke(:exec)).to eq ""
    end
  end
end
