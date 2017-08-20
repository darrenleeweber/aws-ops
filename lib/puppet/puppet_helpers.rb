
module PuppetHelpers
  module_function

  DEPLOY_DIR = 'initial-deployment-puppet'

  def puppet_apply(manifest)
    rsync
    sudo('puppet apply --modulepath ' + DEPLOY_DIR + '/modules ' +
      DEPLOY_DIR + '/manifests/' + manifest)
  end

  def rsync
    rsync_project(
      remote_dir=DEPLOY_DIR,
      local_dir=PROJECT_PATH + '/initial-deployment-puppet/',
      extra_opts='--delete'
    )
  end

end
