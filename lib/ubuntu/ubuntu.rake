
namespace :ubuntu do

  desc 'apt update'
  task :update do
    on roles(:ubuntu), in: :parallel do |host|
      sudo('apt-get -qq update')
    end
  end

  desc 'apt upgrade'
  task :upgrade do
    on roles(:ubuntu), in: :parallel do |host|
      sudo('apt-get -y -qqq upgrade')
    end
  end

  desc 'apt auto-remove'
  task :auto_remove do
    on roles(:ubuntu), in: :parallel do |host|
      sudo('apt-get -y -qqq auto-remove')
    end
  end

  namespace :install do

    desc 'common build tools'
    task :build_tools do
      on roles(:ubuntu), in: :parallel do |host|
        sudo("#{current_path}/lib/bash/debian/build.sh")
        sudo("#{current_path}/lib/bash/debian/ctags.sh")
        sudo("#{current_path}/lib/bash/debian/git.sh")
        sudo("#{current_path}/lib/bash/debian/gradle.sh")
        sudo("#{current_path}/lib/bash/debian/maven.sh")
        sudo("#{current_path}/lib/bash/debian/sbt.sh")
      end
    end

    desc 'common network tools'
    task :network_tools do
      on roles(:ubuntu), in: :parallel do |host|
        sudo("#{current_path}/lib/bash/debian/network.sh")
      end
    end

    desc 'java-7-oracle'
    task :java_7_oracle do
      on roles(:ubuntu), in: :parallel do |host|
        sudo("#{current_path}/lib/bash/debian/java.sh")
        sudo("#{current_path}/lib/bash/debian/java7.sh")
      end
    end

    desc 'java-8-oracle'
    task :java_8_oracle do
      on roles(:ubuntu), in: :parallel do |host|
        sudo("#{current_path}/lib/bash/debian/java.sh")
        sudo("#{current_path}/lib/bash/debian/java8.sh")
      end
    end
  end

end

