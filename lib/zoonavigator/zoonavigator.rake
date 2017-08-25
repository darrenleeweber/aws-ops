
namespace :zoonavigator do

  # ZooNavigator
  # https://github.com/elkozmon/zoonavigator
  #
  # http://test_zookeeper1:8001
  #  - enter the zookeeper connection details, e.g. assuming the /etc/hosts are configured
  #  - test_zookeeper1:2181,test_zookeeper2:2181,test_zookeeper3:2181
  #  - there is no authorization in test

  namespace :service do

    desc 'Install service'
    task :install do
      on roles(:zookeeper), in: :parallel do |host|

        # Install zooNavigator on myid==1
        myid = Settings.aws[host.hostname].myid
        if myid == 1
          puts host.hostname
          sudo("docker-compose -f #{current_path}/lib/zoonavigator/docker-compose-#{fetch(:stage)}.yml up -d")
        end
      end
    end

    desc 'Zookeeper connections'
    task :connections do
      Rake::Task['zookeeper:nodes:connections'].invoke
    end

  end

end

