
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

  # Create zoo.cfg data, something like:
  # server.1=zookeeper1:2888:3888
  # server.2=zookeeper2:2888:3888
  # server.3=zookeeper3:2888:3888
  #
  # leader_port - the first port is for connections to a leader
  # election_port - the second one is used for leader elections
  def zoo_cfg
    alive = manager.nodes_alive
    settings.nodes.map do |n|
      i = alive.find { |i| AwsHelpers.ec2_instance_tag_name?(i, n.tag_name) }
      next if i.nil?
      "server.#{n.myid}=#{n.tag_name}:#{n.leader_port}:#{n.election_port}"
    end
  end

end

