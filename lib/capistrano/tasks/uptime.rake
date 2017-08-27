
# role :demo, %w{example.com example.org example.net}

task :uptime do
  on roles(:all), in: :parallel do |host|
    uptime = capture(:uptime)
    puts "#{host.hostname} reports: #{uptime}"
  end
end

