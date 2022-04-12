namespace :deploy do
  desc 'Deploys the app with puppet'
  task :default do
    run("cd /etc/puppet && git pull")
    run("cd /etc/puppet && ./puppet-apply.sh #{fetch :puppet_param}")
  end
end
