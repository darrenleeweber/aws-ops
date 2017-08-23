
# Utilities for working with the settings for security groups
module AwsSecurityGroupsSettings

  module_function

  def security_group_keys
    Settings.aws.keys.select { |k| k.to_s.include? 'security_group' }
  end

  def security_groups
    security_group_keys
      .map { |k| Settings.aws[k] }
      .reject { |sg| sg.group_name.nil? }
  end

  def group_names
    security_groups.map(&:group_name)
  end

  def find(group_name)
    security_groups.find { |sg| sg.group_name == group_name }
  end

  def to_params(sg_settings)
    JSON.parse(sg_settings.to_json)
  end

end
