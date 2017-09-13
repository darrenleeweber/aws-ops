require_relative 'redhat_helper'

namespace :redhat do
  desc 'logs'
  task :logs do
    on roles(:redhat), in: :parallel do |host|
      execute(redhat_helper.log_path_files)
    end
  end

  desc 'yum update'
  task :update do
    on roles(:redhat), in: :parallel do |host|
      sudo(redhat_helper.yum_update)
    end
  end

  desc 'yum upgrade'
  task :upgrade do
    on roles(:redhat), in: :parallel do |host|
      sudo(redhat_helper.yum_upgrade)
    end
  end

  desc 'yum auto-remove'
  task :auto_remove do
    on roles(:redhat), in: :parallel do |host|
      sudo(redhat_helper.yum_auto_remove)
    end
  end

  # namespace :check do
  #   desc 'docker hello world'
  #   task :docker_hello_world do
  #     on roles(:redhat), in: :parallel do |host|
  #       execute(redhat_helper.docker_hello_world)
  #     end
  #   end
  # end

  namespace :install do
    desc 'common build tools'
    task :build_tools do
      on roles(:redhat), in: :parallel do |host|
        # sudo(redhat_helper.build)
        # sudo(redhat_helper.ctags)
        # sudo(redhat_helper.git)
        # sudo(redhat_helper.gradle)
        # sudo(redhat_helper.maven)
        sudo(redhat_helper.sbt)
      end
    end

    # desc 'docker'
    # task :docker do
    #   Rake::Task['redhat:install:docker_ce'].invoke
    #   Rake::Task['redhat:install:docker_user_add'].invoke
    #   Rake::Task['redhat:check:docker_hello_world'].invoke
    # end
    #
    # desc 'docker community edition (CE)'
    # task :docker_ce do
    #   on roles(:redhat), in: :parallel do |host|
    #     sudo(redhat_helper.docker_ce)
    #   end
    # end
    #
    # desc 'docker - grand user permission to run docker'
    # task :docker_user_add do
    #   on roles(:redhat), in: :parallel do |host|
    #     execute(redhat_helper.docker_add_user)
    #   end
    # end
    #
    # desc 'java oracle license'
    # task :java_oracle_license do
    #   Rake::Task['redhat:install:java_oracle_repository'].invoke
    #   on roles(:redhat), in: :parallel do |host|
    #     sudo(redhat_helper.java_oracle_license)
    #   end
    # end
    #
    # desc 'java oracle repository'
    # task :java_oracle_repository do
    #   on roles(:redhat), in: :parallel do |host|
    #     sudo(redhat_helper.java_oracle_repository)
    #   end
    # end
    #
    # desc 'java-7-oracle'
    # task :java_7_oracle do
    #   Rake::Task['redhat:install:java_oracle_license'].invoke
    #   on roles(:redhat), in: :parallel do |host|
    #     sudo(redhat_helper.java_7_oracle)
    #   end
    # end
    #
    # desc 'java-8-oracle'
    # task :java_8_oracle do
    #   Rake::Task['redhat:install:java_oracle_license'].invoke
    #   on roles(:redhat), in: :parallel do |host|
    #     sudo(redhat_helper.java_8_oracle)
    #   end
    # end
    #
    # desc 'network tools'
    # task :network_tools do
    #   on roles(:redhat), in: :parallel do |host|
    #     sudo(redhat_helper.network_tools)
    #   end
    # end
    #
    # desc 'OS utils'
    # task :os_utils do
    #   on roles(:redhat), in: :parallel do |host|
    #     sudo(redhat_helper.htop)
    #   end
    # end
  end
end

