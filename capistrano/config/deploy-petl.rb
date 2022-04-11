namespace :deploy do
  desc 'Deploys petl with puppet'
  task :default do
    run("cd /etc/puppet && git pull")
    run("cd /etc/puppet && ./puppet-apply.sh petl")
  end
end
