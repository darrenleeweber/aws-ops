
namespace :hdfs do

  desc 'Hadoop initialize'
  task :init do
    on roles(:hdfs), in: :parallel do |host|
      sudo('mkdir -p /raid/hadoop')
    end
  end

  namespace :all do
    desc 'Start Hadoop master and workers'
    task :start do
      Rake::Task['hdfs:master:start'].invoke
      Rake::Task['hdfs:worker:start'].invoke
    end

    desc 'Stop Hadoop master and workers'
    task :stop do
      Rake::Task['hdfs:worker:stop'].invoke
      Rake::Task['hdfs:master:stop'].invoke
    end
  end

  namespace :master do
    desc 'Start Hadoop master'
    task :start do
      on roles(:hdfs_master), in: :parallel do |host|
        PuppetHelpers.puppet_apply('hdfs-master.pp')
      end
    end

    desc 'Stop Hadoop master'
    task :stop do
      on roles(:hdfs_master), in: :parallel do |host|
        sudo('/sbin/service hadoop-hdfs-namenode stop')
        sudo('/sbin/service hadoop-0.20-mapreduce-jobtracker stop')
        sudo('/sbin/service hadoop-mapreduce-historyserver stop')
        sudo('/sbin/service hadoop-yarn-nodemanager stop')
        sudo('/sbin/service hadoop-yarn-resourcemanager stop')
      end
    end
  end

  namespace :worker do
    desc 'Start Hadoop workers'
    task :start do
      on roles(:hdfs_worker), in: :parallel do |host|
        PuppetHelpers.puppet_apply('hdfs-worker.pp')
      end
    end

    desc 'Stop Hadoop workers'
    task :stop do
      on roles(:hdfs_worker), in: :parallel do |host|
        sudo('/sbin/service hadoop-hdfs-datanode stop')
      end
    end
  end
end

