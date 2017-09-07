
# Utilities for working with Zookeeper
module ZookeeperHelpers

  module_function

  SERVICE = 'zookeeper'.freeze

  def settings
    @settings ||= ServiceSettings.new SERVICE
  end

  def manager
    @manager ||= ServiceManager.new SERVICE
  end

  def configuration
    settings.configuration
  end

  # ZooKeeper connection data, something like:
  # zookeeper1:2181,zookeeper2:2181,zookeeper3:2181
  #
  # @param public [Boolean] true by default
  # @return connections [Array<String>]
  def connections(public = true)
    alive = manager.nodes_alive
    settings.nodes.map do |n|
      inst = alive.find { |i| AwsHelpers.ec2_instance_tag_name?(i, n.tag_name) }
      next if inst.nil?
      dns = public ? inst.public_dns_name : inst.private_dns_name
      "#{dns}:#{n.client_port}"
    end
  end

  # Create zoo.cfg data, using private DNS names, something like:
  # server.1=zookeeper1:2888:3888
  # server.2=zookeeper2:2888:3888
  # server.3=zookeeper3:2888:3888
  #
  # leader_port - the first port is for connections to a leader
  # election_port - the second one is used for leader elections
  #
  # @param public [Boolean] false by default
  # @return server_connections [Array<String>]
  def zoo_cfg(public = false)
    alive = manager.nodes_alive
    settings.nodes.map do |n|
      inst = alive.find { |i| AwsHelpers.ec2_instance_tag_name?(i, n.tag_name) }
      next if inst.nil?
      dns = public ? inst.public_dns_name : inst.private_dns_name
      "server.#{n.myid}=#{dns}:#{n.leader_port}:#{n.election_port}"
    end
  end

end

