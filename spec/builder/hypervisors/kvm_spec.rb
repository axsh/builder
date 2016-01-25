require 'spec_helper'

describe Builder::Hypervisors::Kvm do
  before do
    generate_builder_file(:with_one_dcmgr)
    generate_builder_config(:simple)
    Builder::Cli::Root.new
  end

  subject { Builder::Hypervisors::Kvm }

  let(:config) { Builder.config }

  describe "provision" do

    let(:seed_image) { "#{config[:builder_root]}/seed" }

    it "downloads seed image" do
      expect(subject).to receive(:system).with(
        "curl -L #{config[:seed_image_url]} -o #{seed_image}")

      subject.provision(:dcmgr)
    end
  end
end
