require 'spec_helper'

describe Builder::Cli::Root do
  describe "init" do
    it "creates .builder and builder.yml file" do
      Builder::Cli::Root.new.invoke(:init)
      expect(File.exist?(".builder")).to eq true
      expect(File.exist?("builder.yml")).to eq true
    end
  end
end
