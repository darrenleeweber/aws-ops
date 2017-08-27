
namespace :ops do
  namespace :os do
    desc 'initialize configuration'
    task :init do
      on roles(:all), in: :parallel do |host|
        # if not exists('.dotfiles'):
        #     with settings(warn_only=True):
        #     run('git clone --recursive http://github.com/bamos/dotfiles.git .dotfiles')
        # run('./.dotfiles/bootstrap.sh -n')
        # with cd(".dotfiles"):
        #     run('git pull') # Keep dotfiles synchronized.

        unless test('[ -f ~/.ssh/config ]')
          execute 'touch ~/.ssh/config; chmod 600 ~/.ssh/config'
        end

        #
        # TODO: check whether to use host.hostname or something here.
        #
        got_host = capture "grep #{host} ~/.ssh/config"
        unless got_host.include? host
          host_data = 'Host ' + host + '\n  HostName ' + host + '.or1'
          execute "echo #{host_data} >> ~/.ssh/config"
        end
      end
    end

    desc 'CentOs install common software'
    task :init_centos do
      on roles(:centos), in: :parallel do |host|
        sudo('yum install -y java-1.7.0-openjdk-devel make puppet')
      end
    end
  end
end

