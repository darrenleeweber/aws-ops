
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
    manager.nodes_running.map do |inst|
      node = settings.nodes.find { |n| n.tag_name == manager.node_name(inst) }
      dns = public ? inst.public_dns_name : inst.private_dns_name
      "#{dns}:#{node.client_port}"
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
    manager.nodes_running.map do |inst|
      node = settings.nodes.find { |n| n.tag_name == manager.node_name(inst) }
      dns = public ? inst.public_dns_name : inst.private_dns_name
      "server.#{node.myid}=#{dns}:#{node.leader_port}:#{node.election_port}"
    end
  end

end

