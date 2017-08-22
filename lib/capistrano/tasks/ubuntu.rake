
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

  desc 'apt upgrade'
  task :upgrade do
    on roles(:ubuntu), in: :parallel do |host|
      sudo('apt-get -y -qqq auto-remove')
    end
  end

end

