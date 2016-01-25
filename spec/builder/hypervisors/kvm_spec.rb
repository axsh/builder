require 'spec_helper'

describe Builder::Hypervisors::Kvm do
  before do
    generate_builder_file(:with_one_dcmgr)
    generate_builder_config(:simple)
    Builder::Cli::Root.new
  end

  subject { Builder::Hypervisors::Kvm }

  let(:config) { Builder.config }
  let(:name) { :dcmgr }

  describe "provision" do

    let(:node_dir) { "#{config[:builder_root]}/#{name.to_s}" } 

    it "downloads seed image" do
      curl_cmd  = "curl -L #{config[:seed_image_url]} -o #{config[:seed_image_path]}"
      expect(subject).to receive(:system).with(curl_cmd)
      subject.send(:download_seed_image)
    end

    it "creates a directory with node's name" do
      mkdir_cmd = "mkdir -p #{node_dir}"
      expect(subject).to receive(:system).with(mkdir_cmd)
      subject.send(:create_node_dir, node_dir)
    end
  end
end
