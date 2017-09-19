require 'spec_helper'

describe AwsHelpers do
  let(:aws_helpers) { AwsHelpers }

  let(:aws_mocks) { AWS_MOCKS }

  let(:inst) { aws_mocks.instance }

  describe '#config' do
    it 'works' do
      expect(aws_helpers.config).to be_an Hash
    end
    it 'includes credentials' do
      expect(aws_helpers.config).to include :credentials
      expect(aws_helpers.config[:credentials]).to eq aws_helpers.credentials
    end
  end

  describe '#credentials' do
    it 'works' do
      expect(aws_helpers.credentials).to be_an Aws::Credentials
    end
  end

  describe '#credentials?' do
    it 'works' do
      expect(aws_helpers.credentials?).to be true
    end
  end

  describe '#ec2' do
    it 'works' do
      result = aws_helpers.ec2(REGION)
      expect(result).to be_an Aws::EC2::Resource
    end
  end

  # # TODO: auto-generated
  # describe '#ec2_create' do
  #   it 'works' do
  #     params = double('params')
  #     result = aws_helpers.ec2_create(params)
  #     expect(result).not_to be_nil
  #   end
  # end
  #
  # # TODO: auto-generated
  # describe '#ec2_add_tags' do
  #   it 'works' do
  #     inst = double('inst')
  #     tags = double('tags')
  #     result = aws_helpers.ec2_add_tags(inst, tags)
  #     expect(result).not_to be_nil
  #   end
  # end
  #
  # # TODO: auto-generated
  # describe '#ec2_find_group_instances' do
  #   it 'works' do
  #     tag_value = double('tag_value')
  #     result = aws_helpers.ec2_find_group_instances(tag_value)
  #     expect(result).not_to be_nil
  #   end
  # end
  #
  # # TODO: auto-generated
  # describe '#ec2_find_name_instances' do
  #   it 'works' do
  #     tag_value = double('tag_value')
  #     result = aws_helpers.ec2_find_name_instances(tag_value)
  #     expect(result).not_to be_nil
  #   end
  # end
  #
  # # TODO: auto-generated
  # describe '#ec2_find_service_instances' do
  #   it 'works' do
  #     tag_value = double('tag_value')
  #     result = aws_helpers.ec2_find_service_instances(tag_value)
  #     expect(result).not_to be_nil
  #   end
  # end
  #
  # # TODO: auto-generated
  # describe '#ec2_find_stage_instances' do
  #   it 'works' do
  #     tag_value = double('tag_value')
  #     result = aws_helpers.ec2_find_stage_instances(tag_value)
  #     expect(result).not_to be_nil
  #   end
  # end
  #
  # # TODO: auto-generated
  # describe '#ec2_find_instance' do
  #   it 'works' do
  #     instance_id = double('instance_id')
  #     result = aws_helpers.ec2_find_instance(instance_id)
  #     expect(result).not_to be_nil
  #   end
  # end
  #
  # # TODO: auto-generated
  # describe '#ec2_find_instances_by_tag' do
  #   it 'works' do
  #     tag = double('tag')
  #     value = double('value')
  #     result = aws_helpers.ec2_find_instances_by_tag(tag, value)
  #     expect(result).not_to be_nil
  #   end
  # end

  describe '#ec2_instance_tag_name' do
    it 'works' do
      result = aws_helpers.ec2_instance_tag_name(inst)
      expect(result).to be_an String
    end
  end

  describe '#ec2_instance_tag_name?' do
    it 'works' do
      tag_name = double('tag_name')
      result = aws_helpers.ec2_instance_tag_name?(inst, tag_name)
      expect(result).not_to be_nil
    end
    it 'is true when tag_name matches' do
      tag_name = aws_mocks.instance_tag_name
      result = aws_helpers.ec2_instance_tag_name?(inst, tag_name)
      expect(result).to be true
    end
    it 'is false when tag_name is different' do
      result = aws_helpers.ec2_instance_tag_name?(inst, 'clueless')
      expect(result).to be false
    end
  end

  describe '#ec2_instance_info' do
    let(:instance_info) { aws_helpers.ec2_instance_info(inst) }
    it 'works' do
      expect(instance_info).to be_an Hash
    end
    it 'contains ID' do
      expect(instance_info).to include 'ID'
      expect(instance_info['ID']).to be_an String
    end
    it 'contains A. Zone' do
      expect(instance_info).to include 'A. Zone'
      expect(instance_info['A. Zone']).to be_an String
    end
    it 'contains AMI ID' do
      expect(instance_info).to include 'AMI ID'
      expect(instance_info['AMI ID']).to be_an String
    end
    it 'contains Key Pair' do
      expect(instance_info).to include 'Key Pair'
      expect(instance_info['Key Pair']).to be_an String
    end
    it 'contains Public DNS' do
      expect(instance_info).to include 'Public DNS'
      expect(instance_info['Public DNS']).to be_an String
    end
    it 'contains Private DNS' do
      expect(instance_info).to include 'Private DNS'
      expect(instance_info['Private DNS']).to be_an String
    end
    it 'contains Public IP' do
      expect(instance_info).to include 'Public IP'
      expect(instance_info['Public IP']).to be_an String
    end
    it 'contains Private IP' do
      expect(instance_info).to include 'Private IP'
      expect(instance_info['Private IP']).to be_an String
    end
    it 'contains State' do
      expect(instance_info).to include 'State'
      expect(instance_info['State']).to be_an String
      expect(instance_info['State']).to eq 'running'
    end
    it 'contains Tags' do
      expect(instance_info).to include 'Tags'
      expect(instance_info['Tags']).to be_an String
    end
    it 'contains Type' do
      expect(instance_info).to include 'Type'
      expect(instance_info['Type']).to be_an String
    end
  end

  describe '#ec2_instances_describe' do
    it 'works' do
      result = aws_helpers.ec2_instances_describe(aws_mocks.instances)
      expect(result).to be_an Array
      expect(result.first).to be_an String
    end
  end

  describe '#ec2_instance_describe' do
    it 'works' do
      result = aws_helpers.ec2_instance_describe(inst)
      expect(result).to be_an String
    end
  end

  describe '#ec2_instance_etc_hosts' do
    let(:etc_hosts) { aws_helpers.ec2_instance_etc_hosts(inst) }
    it 'works' do
      expect(etc_hosts).to be_an String
    end
    it 'starts with Public IP' do
      expect(etc_hosts).to start_with inst.public_ip_address
    end
    it 'includes Public DNS' do
      expect(etc_hosts).to include inst.public_dns_name
    end
    it 'includes Private DNS' do
      expect(etc_hosts).to include inst.private_dns_name
    end
  end

  describe '#ec2_instance_ssh_config' do
    let(:ssh_config) { aws_helpers.ec2_instance_ssh_config(inst, true) }
    it 'works' do
      expect(ssh_config).to be_an String
    end
    it 'includes a {HOST} template' do
      expect(ssh_config).to include '{HOST}'
    end
    it 'includes a {USER} template' do
      expect(ssh_config).to include '{USER}'
    end
    it 'includes a Public DNS' do
      expect(ssh_config).to include inst.public_dns_name
    end
    it 'includes an AWS Key Pair' do
      expect(ssh_config).to include inst.key_name
    end
  end

  # # TODO: auto-generated
  # describe '#ec2_start_instance' do
  #   it 'works' do
  #     instance_id = double('instance_id')
  #     result = aws_helpers.ec2_start_instance(instance_id)
  #     expect(result).not_to be_nil
  #   end
  # end
  #
  # # TODO: auto-generated
  # describe '#ec2_stop_instance' do
  #   it 'works' do
  #     instance_id = double('instance_id')
  #     result = aws_helpers.ec2_stop_instance(instance_id)
  #     expect(result).not_to be_nil
  #   end
  # end
  #
  # # TODO: auto-generated
  # describe '#ec2_reboot_instance' do
  #   it 'works' do
  #     instance_id = double('instance_id')
  #     result = aws_helpers.ec2_reboot_instance(instance_id)
  #     expect(result).not_to be_nil
  #   end
  # end
  #
  # # TODO: auto-generated
  # describe '#ec2_terminate_instance' do
  #   it 'works' do
  #     instance_id = double('instance_id')
  #     result = aws_helpers.ec2_terminate_instance(instance_id)
  #     expect(result).not_to be_nil
  #   end
  # end
  #
  # # TODO: auto-generated
  # describe '#ec2_wait_instance_startup' do
  #   it 'works' do
  #     instance_ids = double('instance_ids')
  #     result = aws_helpers.ec2_wait_instance_startup(instance_ids)
  #     expect(result).not_to be_nil
  #   end
  # end
  #
  # # TODO: auto-generated
  # describe '#ec2_wait_instance_stopped' do
  #   it 'works' do
  #     instance_ids = double('instance_ids')
  #     result = aws_helpers.ec2_wait_instance_stopped(instance_ids)
  #     expect(result).not_to be_nil
  #   end
  # end
  #
  # # TODO: auto-generated
  # describe '#ec2_wait_instance_terminated' do
  #   it 'works' do
  #     instance_ids = double('instance_ids')
  #     result = aws_helpers.ec2_wait_instance_terminated(instance_ids)
  #     expect(result).not_to be_nil
  #   end
  # end
end

