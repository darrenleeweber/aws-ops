require 'aws-sdk-ec2'

# Utilities for working with the AWS API, see
# http://docs.aws.amazon.com/sdk-for-ruby/v2/developer-guide/examples.html
# http://docs.aws.amazon.com/sdk-for-ruby/v2/developer-guide/ec2-examples.html
module AwsVPC

  module_function

  def ec2(region = nil)
    @ec2 ||= begin
      region ||= Settings.aws.region
      Aws::EC2::Client.new(region: region)
    end
  end

  # # The following example creates the virtual private cloud (VPC) MyGroovyVPC
  # # with the CIDR block 10.200.0.0/16, and then displays the VPC's ID.
  # # The example creates a virtual network with 65,536 private IP addresses.
  # def create_vpc
  #   vpc = ec2.create_vpc({ cidr_block: '10.200.0.0/16' })
  #   # So we get a public DNS
  #   vpc.modify_attribute({ enable_dns_support:   { value: true } })
  #   vpc.modify_attribute({ enable_dns_hostnames: { value: true } })
  #   # Name our VPC
  #   vpc.create_tags({ tags: [{ key: 'Name', value: 'MyGroovyVPC' }]})
  #   puts vpc.vpc_id
  #   vpc
  # end

end

