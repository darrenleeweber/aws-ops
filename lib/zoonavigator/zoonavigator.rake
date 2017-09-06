
namespace :zoonavigator do
  # ZooNavigator
  # https://github.com/elkozmon/zoonavigator
  #
  # http://test_zookeeper1:8001
  #  - enter the zookeeper connection details, e.g. assuming the /etc/hosts are configured
  #  - test_zookeeper1:2181,test_zookeeper2:2181,test_zookeeper3:2181
  #  - there is no authorization in test

  # Install docker and docker-compose
  def zoonavigator_install_docker
    sudo(ubuntu_helper.docker_ce)
    execute(ubuntu_helper.docker_add_user)
    execute(ubuntu_helper.docker_hello_world)
  end

  namespace :service do
    desc 'Install service'
    task :install do
      on roles(:zookeeper), in: :parallel do |host|
        if host_settings['myid'] == 1
          puts host.hostname
          zoonavigator_install_docker
          sudo("docker-compose -f #{current_path}/lib/zoonavigator/docker-compose.yml up -d")
        end
      end
    end

    desc 'Zookeeper connections'
    task :connections do
      Rake::Task['zookeeper:nodes:connections'].invoke
    end
  end
end

