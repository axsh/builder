require 'spec_helper'

describe Builder::Hypervisors::Kvm do
  before do
    generate_builder_file(:with_one_dcmgr)
    generate_builder_config(:simple)
    Builder::Cli::Root.new
  end

  subject { Builder::Hypervisors::Kvm }

  let(:config) { Builder.config }
  let(:nodes) { Builder.recipe[:nodes] }
  let(:name) { :dcmgr }

  describe "provision" do

    let(:node_dir) { "#{config[:builder_root]}/#{name.to_s}" } 
    let(:node_image_path) { "#{node_dir}/#{name.to_s}.raw" }

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

      subject.send(:extract_seed_image, node_image_path)

      expect(File.exist?(node_image_path)).to eq true

      File.delete('test')
      File.delete(config[:seed_image_path])
      FileUtils.rm_rf(node_dir)

      FakeFS.activate!
    end

    it "creates ifcfg-xxx files according to node's spec" do
      nics = nodes[:dcmgr][:provision][:spec][:nics]

      nics.keys.each do |nic|
        allow(File).to receive(:open)
          .with("#{node_dir}/mnt/etc/sysconfig/network-scripts/ifcfg-#{nic}", "w")
      end

      mkdir_cmd = "mkdir -p #{node_dir}/mnt"
      mount_cmd = "mount -o loop,offset=32256 #{node_image_path} #{node_dir}/mnt"

      allow(subject).to receive(:system).with(mkdir_cmd)
      allow(subject).to receive(:system).with(mount_cmd)

      expect{
        subject.send(:create_nics, nics, node_dir, node_image_path)
      }.not_to raise_error
    end
  end
end
