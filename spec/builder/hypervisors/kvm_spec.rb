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

    it "extracs seed image to node's directory" do

      FakeFS.deactivate!

      File.open('test', 'w') do |f|
        f.puts "fake data"
      end

      Zlib::GzipWriter.open(config[:seed_image_path], Zlib::BEST_COMPRESSION) do |gz|
        out = Archive::Tar::Minitar::Output.new(gz)
        Archive::Tar::Minitar::pack_file('test', out)
        out.close
      end

      node_image_dir = "#{config[:builder_root]}/#{name.to_s}"
      node_image_path = "#{config[:builder_root]}/#{name.to_s}/#{name.to_s}.raw"

      subject.send(:extract_seed_image, node_image_path)

      expect(File.exist?(node_image_path)).to eq true

      File.delete('test')
      File.delete(config[:seed_image_path])
      FileUtils.rm_rf(node_image_dir)

      FakeFS.activate!
    end
  end
end
