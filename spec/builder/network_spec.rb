require 'spec_helper'

describe Builder::Networks do

  before do
    generate_builder_file(:with_one_network)
    generate_builder_config(:simple)
    Builder::Cli::Root.new
  end

  subject { Builder::Networks }

  describe "provision" do
    it "creates and configures bridges as written in builder.yml" do

      allow(subject).to receive(:system).with(/add/).and_return(true)
      allow(subject).to receive(:system).with(/ifup/).and_return(true)

      expect {
        subject.provision(:local)
      }.not_to raise_error
    end
  end
end
