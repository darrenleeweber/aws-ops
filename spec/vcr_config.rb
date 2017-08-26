require 'vcr'

# Use VCR for inspecting some of the payload data and to enable specs on
# travis.ci (without entirely mocking all the AWS API calls).  It can also help
# to speed up specs when the fixture data is not changing much.  Note that the
# `vcr_config` has filters in it to strip out sensitive information and replace
# AWS resource IDs with random values.  The random values can help to ensure
# that specs using these fixtures do not get fixated on static values, because
# the AWS resources IDs can be replaced any time a resource is restarted or
# replaced.

VCR.configure do |c|
  c.cassette_library_dir = 'fixtures/vcr_cassettes'
  c.allow_http_connections_when_no_cassette = true
  c.hook_into :webmock
  c.default_cassette_options = {
    record: :new_episodes # :once is default
  }
  c.configure_rspec_metadata!

  # ---
  # Filter helpers

  def randomize_captures(data, match)
    alphanum = [*0..9] + [*'A'..'Z']
    match.captures.each do |cap|
      data.gsub!(cap, alphanum.sample(cap.length).join)
    end
  end

  def randomize_aws_ids(data, match)
    alphanum = [*0..9] + [*'a'..'f']
    match.captures.each do |cap|
      data.gsub!(cap, alphanum.sample(cap.length).join)
    end
  end

  def randomize_aws_ips(data, match)
    ip_nums = [*0..255].sample(4).join('.')
    dns_nums = ip_nums.tr('.', '-')
    match.captures.each do |ip_cap|
      data.gsub!(ip_cap, ip_nums)
      # Also use the same IP in the DNS names
      dns_cap = ip_cap.tr('.', '-')
      data.gsub!(dns_cap, dns_nums)
    end
  end

  # ---
  # Request Headers

  c.filter_sensitive_data('CREDENTIAL') do |interaction|
    auth_headers = interaction.request.headers['Authorization']
    if auth_headers.is_a? Array
      auth_headers.each do |auth|
        match = auth.match(/Credential=(.*?)\//)
        randomize_captures(auth, match) if match
      end
    end
  end

  c.filter_sensitive_data('SIGNATURE') do |interaction|
    auth_headers = interaction.request.headers['Authorization']
    if auth_headers.is_a? Array
      auth_headers.each do |auth|
        match = auth.match(/Signature=(.*)/)
        randomize_captures(auth, match) if match
      end
    end
  end

  # ---
  # Response Body

  c.filter_sensitive_data('KEY_NAME') do |interaction|
    body = interaction.response.body
    match = body.match(/<keyName>(.*)<\/keyName>/)
    randomize_captures(body, match) if match
  end

  c.filter_sensitive_data('OWNER') do |interaction|
    match = interaction.response.body.match(/<ownerId>(.*)<\/ownerId>/)
    if match
      match.captures.each do |owner|
        zeros = owner.to_s.gsub(/\d/, '0')
        interaction.response.body.gsub!(owner, zeros)
      end
    end
  end

  c.filter_sensitive_data('AWS_IDS') do |interaction|
    body = interaction.response.body
    match = body.match(/<instanceId>i-(.*)<\/instanceId>/)
    randomize_aws_ids(body, match) if match
    match = body.match(/<groupId>sg-(.*)<\/groupId>/)
    randomize_aws_ids(body, match) if match
    match = body.match(/<volumeId>vol-(.*)<\/volumeId>/)
    randomize_aws_ids(body, match) if match
    match = body.match(/<networkInterfaceId>eni-(.*)<\/networkInterfaceId>/)
    randomize_aws_ids(body, match) if match
    match = body.match(/<attachmentId>eni-attach-(.*)<\/attachmentId>/)
    randomize_aws_ids(body, match) if match
    match = body.match(/<publicIp>(.*)<\/publicIp>/)
    randomize_aws_ips(body, match) if match
    match = body.match(/<privateIpAddress>(.*)<\/privateIpAddress>/)
    randomize_aws_ips(body, match) if match
    match = body.match(/<ipAddress>(.*)<\/ipAddress>/)
    randomize_aws_ips(body, match) if match
  end

end
