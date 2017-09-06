require_relative 'zookeeper_helpers'

namespace :zookeeper do
  namespace :service do
    desc 'Install service'
    task :install do
      on roles(:zookeeper), in: :parallel do |host|
        # PuppetHelpers.puppet_apply('zookeeper.pp')
        install_java8
        sudo(ubuntu_helper.zookeeper)
      end
    end

    desc 'Upgrade service'
    task :upgrade do
      on roles(:zookeeper), in: :parallel do |host|
        sudo(ubuntu_helper.zookeeper_upgrade)
      end
    end
  end
end

