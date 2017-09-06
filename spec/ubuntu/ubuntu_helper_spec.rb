# -*- encoding: utf-8 -*-

require 'spec_helper'

describe UbuntuHelper do
  let(:current_path) { 'current_path' }
  let(:ubuntu_helper) { UbuntuHelper.new(current_path) }

  shared_examples 'an_apt_command' do
    it 'is an apt command' do
      expect(result).to be_an String
      expect(result).to include 'apt'
    end
  end

  shared_examples 'logs_output' do
    it 'logs output' do
      expect(result).to be_an String
      expect(result).to end_with '.log'
    end
  end

  describe '#new' do
    it 'works' do
      current_path = double('current_path')
      result = UbuntuHelper.new(current_path)
      expect(result).not_to be_nil
    end
  end

  describe '#apt_update' do
    let(:result) { ubuntu_helper.apt_update }
    it_behaves_like 'an_apt_command'
    it_behaves_like 'logs_output'
    it 'calls update' do
      expect(result).to include 'update'
    end
  end

  describe '#apt_upgrade' do
    let(:result) { ubuntu_helper.apt_upgrade }
    it_behaves_like 'an_apt_command'
    it_behaves_like 'logs_output'
    it 'calls upgrade' do
      expect(result).to include 'upgrade'
    end
  end

  describe '#apt_auto_remove' do
    let(:result) { ubuntu_helper.apt_auto_remove }
    it_behaves_like 'an_apt_command'
    it_behaves_like 'logs_output'
    it 'calls auto_remove' do
      expect(result).to include 'auto-remove'
    end
  end

  describe '#build' do
    let(:result) { ubuntu_helper.build }
    it_behaves_like 'logs_output'
    it 'calls build.sh' do
      expect(result).to include 'build.sh'
    end
  end

  describe '#ctags' do
    let(:result) { ubuntu_helper.ctags }
    it_behaves_like 'logs_output'
    it 'calls ctags.sh' do
      expect(result).to include 'ctags.sh'
    end
  end

  describe '#docker_add_user' do
    let(:result) { ubuntu_helper.docker_add_user }
    it 'calls usermod -a -G docker' do
      expect(result).to include 'usermod -a -G docker'
    end
  end

  describe '#docker_ce' do
    let(:result) { ubuntu_helper.docker_ce }
    it_behaves_like 'logs_output'
    it 'calls docker_ce.sh' do
      expect(result).to include 'docker_ce.sh'
    end
  end

  describe '#docker_hello_world' do
    let(:result) { ubuntu_helper.docker_hello_world }
    it 'calls docker run hello-world' do
      expect(result).to include 'docker run hello-world'
    end
  end

  describe '#git' do
    let(:result) { ubuntu_helper.git }
    it_behaves_like 'logs_output'
    it 'calls git.sh' do
      expect(result).to include 'git.sh'
    end
  end

  describe '#gradle' do
    let(:result) { ubuntu_helper.gradle }
    it_behaves_like 'logs_output'
    it 'calls gradle.sh' do
      expect(result).to include 'gradle.sh'
    end
  end

  describe '#htop' do
    let(:result) { ubuntu_helper.htop }
    it_behaves_like 'logs_output'
    it 'calls htop.sh' do
      expect(result).to include 'htop.sh'
    end
  end

  describe '#java_oracle_license' do
    let(:result) { ubuntu_helper.java_oracle_license }
    it_behaves_like 'logs_output'
    it 'calls java_oracle_license.sh' do
      expect(result).to include 'java_oracle_license.sh'
    end
  end

  describe '#java_oracle_repository' do
    let(:result) { ubuntu_helper.java_oracle_repository }
    it_behaves_like 'logs_output'
    it 'calls java_oracle_repository.sh' do
      expect(result).to include 'java_oracle_repository.sh'
    end
  end

  describe '#java_7_oracle' do
    let(:result) { ubuntu_helper.java_7_oracle }
    it_behaves_like 'logs_output'
    it 'calls java_7_oracle.sh' do
      expect(result).to include 'java_7_oracle.sh'
    end
  end

  describe '#java_8_oracle' do
    let(:result) { ubuntu_helper.java_8_oracle }
    it_behaves_like 'logs_output'
    it 'calls java_8_oracle.sh' do
      expect(result).to include 'java_8_oracle.sh'
    end
  end

  describe '#kafka_bin' do
    let(:kafka_ver) { '2.10 1.0.0' }
    let(:result) { ubuntu_helper.kafka_bin(kafka_ver) }
    it_behaves_like 'logs_output'
    it 'calls kafka_bin.sh' do
      expect(result).to include 'kafka_bin.sh'
    end
    it 'passes along scala and kafka versions' do
      expect(result).to include kafka_ver
    end
  end

  describe '#log_path_files' do
    let(:result) { ubuntu_helper.log_path_files }
    it 'calls find' do
      expect(result).to include 'find'
    end
  end

  describe '#maven' do
    let(:result) { ubuntu_helper.maven }
    it_behaves_like 'logs_output'
    it 'calls maven.sh' do
      expect(result).to include 'maven.sh'
    end
  end

  describe '#network_tools' do
    let(:result) { ubuntu_helper.network_tools }
    it_behaves_like 'logs_output'
    it 'calls network_tools.sh' do
      expect(result).to include 'network_tools.sh'
    end
  end

  describe '#sbt' do
    let(:result) { ubuntu_helper.sbt }
    it_behaves_like 'logs_output'
    it 'calls sbt.sh' do
      expect(result).to include 'sbt.sh'
    end
  end

  describe '#zookeeper' do
    let(:result) { ubuntu_helper.zookeeper }
    it_behaves_like 'logs_output'
    it 'calls zookeeper.sh' do
      expect(result).to include 'zookeeper.sh'
    end
  end

  describe '#zookeeper_upgrade' do
    let(:result) { ubuntu_helper.zookeeper_upgrade }
    it_behaves_like 'an_apt_command'
    it_behaves_like 'logs_output'
    it 'calls --only-upgrade zookeeper' do
      expect(result).to include '--only-upgrade zookeeper'
    end
  end
end

