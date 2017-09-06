require_relative 'ubuntu_helper'

namespace :ubuntu do
  desc 'logs'
  task :logs do
    on roles(:ubuntu), in: :parallel do |host|
      execute(ubuntu_helper.log_path_files)
    end
  end

  desc 'apt update'
  task :update do
    on roles(:ubuntu), in: :parallel do |host|
      sudo(ubuntu_helper.apt_update)
    end
  end

  desc 'apt upgrade'
  task :upgrade do
    on roles(:ubuntu), in: :parallel do |host|
      sudo(ubuntu_helper.apt_upgrade)
    end
  end

  desc 'apt auto-remove'
  task :auto_remove do
    on roles(:ubuntu), in: :parallel do |host|
      sudo(ubuntu_helper.apt_auto_remove)
    end
  end

  namespace :check do
    desc 'docker hello world'
    task :docker_hello_world do
      on roles(:ubuntu), in: :parallel do |host|
        execute(ubuntu_helper.docker_hello_world)
      end
    end
  end

  namespace :install do
    desc 'common build tools'
    task :build_tools do
      on roles(:ubuntu), in: :parallel do |host|
        sudo(ubuntu_helper.build)
        sudo(ubuntu_helper.ctags)
        sudo(ubuntu_helper.git)
        sudo(ubuntu_helper.gradle)
        sudo(ubuntu_helper.maven)
        sudo(ubuntu_helper.sbt)
      end
    end

    desc 'docker'
    task :docker do
      Rake::Task['ubuntu:install:docker_ce'].invoke
      Rake::Task['ubuntu:install:docker_user_add'].invoke
      Rake::Task['ubuntu:check:docker_hello_world'].invoke
    end

    desc 'docker community edition (CE)'
    task :docker_ce do
      on roles(:ubuntu), in: :parallel do |host|
        sudo(ubuntu_helper.docker_ce)
      end
    end

    desc 'docker - grand user permission to run docker'
    task :docker_user_add do
      on roles(:ubuntu), in: :parallel do |host|
        execute(ubuntu_helper.docker_add_user)
      end
    end

    desc 'java oracle license'
    task :java_oracle_license do
      Rake::Task['ubuntu:install:java_oracle_repository'].invoke
      on roles(:ubuntu), in: :parallel do |host|
        sudo(ubuntu_helper.java_oracle_license)
      end
    end

    desc 'java oracle repository'
    task :java_oracle_repository do
      on roles(:ubuntu), in: :parallel do |host|
        sudo(ubuntu_helper.java_oracle_repository)
      end
    end

    desc 'java-7-oracle'
    task :java_7_oracle do
      Rake::Task['ubuntu:install:java_oracle_license'].invoke
      on roles(:ubuntu), in: :parallel do |host|
        sudo(ubuntu_helper.java_7_oracle)
      end
    end

    desc 'java-8-oracle'
    task :java_8_oracle do
      Rake::Task['ubuntu:install:java_oracle_license'].invoke
      on roles(:ubuntu), in: :parallel do |host|
        sudo(ubuntu_helper.java_8_oracle)
      end
    end

    desc 'network tools'
    task :network_tools do
      on roles(:ubuntu), in: :parallel do |host|
        sudo(ubuntu_helper.network_tools)
      end
    end

    desc 'OS utils'
    task :os_utils do
      on roles(:ubuntu), in: :parallel do |host|
        sudo(ubuntu_helper.htop)
      end
    end
  end
end

