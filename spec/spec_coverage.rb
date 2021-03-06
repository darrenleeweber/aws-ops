
require 'single_cov'
SingleCov.setup :rspec

require 'simplecov'

SimpleCov.profiles.define 'aws_ops' do
  add_filter '.gems'
  add_filter '/config/settings/'
  add_filter 'pkg'
  add_filter 'spec'
  add_filter 'vendor'

  # Simplecov can detect changes using data from the
  # last rspec run.  Travis will never have a previous
  # dataset for comparison, so it can't fail a travis build.
  maximum_coverage_drop 0.1
end
SimpleCov.start 'aws_ops'

