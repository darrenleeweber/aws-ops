
namespace :ubuntu do

  desc 'apt update'
  task :update do
    on roles(:ubuntu), in: :parallel do |host|
      sudo("apt-get -y -q update > #{current_path}/log/apt_get_update.log")
    end
  end

  desc 'apt upgrade'
  task :upgrade do
    on roles(:ubuntu), in: :parallel do |host|
      sudo("apt-get -y -q upgrade > #{current_path}/log/apt_get_upgrade.log")
    end
  end

  desc 'apt auto-remove'
  task :auto_remove do
    on roles(:ubuntu), in: :parallel do |host|
      sudo("apt-get -y -q auto-remove > #{current_path}/log/apt_get_auto_remove.log")
    end
  end

  namespace :install do

    desc 'common build tools'
    task :build_tools do
      on roles(:ubuntu), in: :parallel do |host|
        sudo("#{current_path}/lib/bash/debian/build.sh  > #{current_path}/log/bash_build.log")
        sudo("#{current_path}/lib/bash/debian/ctags.sh  > #{current_path}/log/bash_ctags.log")
        sudo("#{current_path}/lib/bash/debian/git.sh    > #{current_path}/log/bash_git.log")
        sudo("#{current_path}/lib/bash/debian/gradle.sh > #{current_path}/log/bash_gradle.log")
        sudo("#{current_path}/lib/bash/debian/maven.sh  > #{current_path}/log/bash_maven.log")
        sudo("#{current_path}/lib/bash/debian/sbt.sh    > #{current_path}/log/bash_sbt.log")
      end
    end

    desc 'common network tools'
    task :network_tools do
      on roles(:ubuntu), in: :parallel do |host|
        sudo("#{current_path}/lib/bash/debian/network.sh > #{current_path}/log/bash_network.log")
      end
    end

    desc 'java oracle license'
    task :java_oracle_license do
      on roles(:ubuntu), in: :parallel do |host|
        sudo("#{current_path}/lib/bash/debian/java.sh  > #{current_path}/log/bash_java.log")
      end
    end

    desc 'java-7-oracle'
    task :java_7_oracle do
      Rake::Task['ubuntu:install:java_oracle_license'].invoke
      on roles(:ubuntu), in: :parallel do |host|
        sudo("#{current_path}/lib/bash/debian/java7.sh > #{current_path}/log/bash_java7.log")
      end
    end

    desc 'java-8-oracle'
    task :java_8_oracle do
      Rake::Task['ubuntu:install:java_oracle_license'].invoke
      on roles(:ubuntu), in: :parallel do |host|
        sudo("#{current_path}/lib/bash/debian/java8.sh > #{current_path}/log/bash_java8.log")
      end
    end
  end

end

