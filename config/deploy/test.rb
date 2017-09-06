# server-based syntax
# ======================
# Defines a single server with a list of roles and multiple properties.
# You can define all roles on a single server, or split them:

# server "example.com", user: "deploy", roles: %w{app db web}, my_property: :my_value
# server "example.com", user: "deploy", roles: %w{app web}, other_property: :other_value
# server "db.example.com", user: "deploy", roles: %w{db}

# Note that it is the `role` assigned to each server that determines
# what services are installed and configured on the server.  The
# operating system on the server is a defined `role` (e.g. 'ubuntu'). The
# software to be installed/configured etc. is a `role`. For example,
# the lib/zookeeper/zookeeper_service.rake namespace refers to the `role`
# of each server.  Although the general assumption is that each server is
# dedicated to running one service, it's possible to assign multiple
# services to any server.  For example, it should be possible to run
# zookeeper and kafka on the same server, just by adding those roles:
# server 'test_zookeeper_kafka1', user: 'ubuntu', roles: %w[kafka ubuntu zookeeper]

# These server aliases match the instance tag:Name and the connection details
# are managed in ~/.ssh/config

# A convention here is that each zookeeper host name ends with a unique digit
# in the range of i in 1 <= i <= 255; this value corresponds to the value in
# /etc/zookeeper/conf/myid on zookeeper servers.  Also, these hostnames
# will be added to the /etc/hosts file on zookeeper servers and associated with
# AWS IPs. See related zookeeper details in:
# - lib/zookeeper/zoo.cfg.{stage}
# - lib/zookeeper/zookeeper_configure.rake

server 'test_zookeeper1', user: 'ubuntu', roles: %w[ubuntu zookeeper]
server 'test_zookeeper2', user: 'ubuntu', roles: %w[ubuntu zookeeper]
server 'test_zookeeper3', user: 'ubuntu', roles: %w[ubuntu zookeeper]


# A convention here is that each kafka host name ends with a unique digit;
# this value corresponds to the broker.id in the server.properties file.
# Also, these hostnames are added to the /etc/hosts file.

server 'test_kafka1', user: 'ubuntu', roles: %w[ubuntu kafka]
server 'test_kafka2', user: 'ubuntu', roles: %w[ubuntu kafka]
server 'test_kafka3', user: 'ubuntu', roles: %w[ubuntu kafka]


# role-based syntax
# ==================

# Defines a role with one or multiple servers. The primary server in each
# group is considered to be the first unless any hosts have the primary
# property set. Specify the username and a domain or IP for the server.
# Don't use `:all`, it's a meta role.

# role :app, %w{deploy@example.com}, my_property: :my_value
# role :web, %w{user1@primary.com user2@additional.com}, other_property: :other_value
# role :db,  %w{deploy@example.com}



# Configuration
# =============
# You can set any configuration variable like in config/deploy.rb
# These variables are then only loaded and set in this stage.
# For available Capistrano configuration variables see the documentation page.
# http://capistranorb.com/documentation/getting-started/configuration/
# Feel free to add new variables to customise your setup.



# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a
# limited set of options, consult the Net::SSH documentation.
# http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start
#
# Global options
# --------------
#  set :ssh_options, {
#    keys: %w(/home/rlisowski/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }
#
# The server-based syntax can be used to override options:
# ------------------------------------
# server "example.com",
#   user: "user_name",
#   roles: %w{web app},
#   ssh_options: {
#     user: "user_name", # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: "please use keys"
#   }
