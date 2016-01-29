require_relative 'spec_helper'

require 'aws-sdk'

describe "aws" do
  before(:all) do
    generate_builder_file(:aws_with_one_network, false)
    generate_builder_config(:aws, false)
  end

  after(:all) do
    config = Builder.config
    vpc_info = Builder.recipe[:vpc_info]
    ::Aws.config.update({
      region: config[:aws_region],
      credentials: ::Aws::Credentials.new(config[:aws_access_key], config[:aws_secret_key])
    })
    ec2 = ::Aws::EC2::Client.new
    ec2.delete_vpc(id: vpc_info[:vpc_id])
  end

  subject { Builder::Cli::Root.new }

  let(:name) { :aws }
  let(:config) { Builder.config }

  let(:nodes) { Builder.recipe[:nodes] }
  let(:networks) { Builder.recipe[:networks] }

  describe "create an AWS instance" do
    subject.invoke(:exec)
    expect(ping_to(nodes[name][:ssh][:ip])).to eq true
  end
end
