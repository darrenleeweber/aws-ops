
namespace :spark do
  namespace :all do
    desc 'Start Spark master and workers'
    task :start do
      Rake::Task['spark:master:start'].invoke
      Rake::Task['spark:worker:start'].invoke
    end

    desc 'Stop Spark master and workers'
    task :stop do
      Rake::Task['spark:worker:stop'].invoke
      Rake::Task['spark:master:stop'].invoke
    end
  end

  namespace :master do
    desc 'Start Spark master'
    task :start do
      on roles(:spark_master), in: :parallel do |host|
        PuppetHelpers.puppet_apply('spark-master.pp')
      end
    end

    desc 'Stop Spark master'
    task :stop do
      on roles(:spark_master), in: :parallel do |host|
        # with settings(warn_only=True):
        sudo('/sbin/initctl stop spark-master')
      end
    end
  end

  namespace :worker do
    desc 'Start Spark workers'
    task :start do
      on roles(:spark_worker), in: :parallel do |host|
        PuppetHelpers.puppet_apply('spark-worker.pp')
      end
    end

    desc 'Stop Spark workers'
    task :stop do
      on roles(:spark_worker), in: :parallel do |host|
        # with settings(warn_only=True):
        sudo('/sbin/initctl stop spark-worker')
      end
    end
  end
end

