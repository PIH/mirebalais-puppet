class apache2 (
  $tomcat = hiera('tomcat'),
  $services_ensure = hiera('services_ensure'),
  $services_enable = hiera('services_enable'),
  $site_domain = hiera('site_domain'),
  $webapp_name = hiera('webapp_name'),
  $ssl_cert_file = hiera('ssl_cert_file'),
  $ssl_chain_file = hiera('ssl_chain_file'),
  $ssl_key_file = hiera('ssl_key_file'),
  $ssl_cert_dir = hiera('ssl_cert_dir'),
  $ssl_key_dir = hiera('ssl_key_dir'),
  $ssl_use_letsencrypt = hiera('ssl_use_letsencrypt'),
  $biometrics_enabled = hiera('biometrics_enabled'),
  $biometrics_webapp_name = hiera('biometrics_webapp_name'),
  $biometrics_port = hiera('biometrics_port'),
  $pwa_enabled = hiera('pwa_enabled'),
  $pwa_webapp_name = hiera('pwa_webapp_name'),
  $keyserver = hiera('keyserver'),
  $letsencrypt_user = decrypt(hiera('letsencrypt_user')),
  $letsencrypt_user_password = decrypt(hiera('letsencrypt_user_password')),
  $sysadmin_email = hiera('sysadmin_email'),
  $azure_dns_subscription_id = decrypt(hiera('azure_dns_subscription_id')),
  $azure_dns_tenant_id = decrypt(hiera('azure_dns_tenant_id')),
  $azure_dns_app_id = decrypt(hiera('azure_dns_app_id')),
  $azure_dns_client_secret = decrypt(hiera('azure_dns_client_secret')),
){

  # really ugly way to do string concat, ignoring empties
  $worker_list = join(split("${webapp_name} ${pwa_webapp_name} ${biometrics_webapp_name}", '\s+'), ',')

  package { 'apache2':
    ensure => installed,
  }

  package { 'libapache2-mod-jk':
    ensure => installed,
  }

  # ensure symlink created between sites enabled and sites available (should happen automatically but I blew this away in one case)
  file { '/etc/apache2/sites-enabled/default-ssl.conf':
    ensure  => link,
    target  => '../sites-available/default-ssl.conf',
    require => Package['apache2']
  }

  file { '/etc/logrotate.d/apache2':
    ensure  => file,
    content  => template('apache2/logrotate.erb')
  }

  file { '/etc/apache2/workers.properties':
    ensure  => present,
    content => template('apache2/workers.properties.erb'),
    notify  => Service['apache2']
  }

  file { '/etc/apache2/ports.conf':
    ensure => present,
    source => 'puppet:///modules/apache2/ports.conf',
    notify => Service['apache2']
  }

  file { '/etc/apache2/mods-available/jk.conf':
    ensure => present,
    source => 'puppet:///modules/apache2/jk.conf',
    notify => Service['apache2']
  }

  file { '/etc/apache2/sites-available/default':
    ensure => absent
  }

  file { '/etc/apache2/sites-available/000-default.conf':
    ensure => file,
    source => 'puppet:///modules/apache2/sites-available/000-default.conf',
    notify => Service['apache2']
  }

  file { '/etc/apache2/sites-available/default-ssl.conf':
    ensure => file,
    content => template('apache2/default-ssl.conf.erb'),
    notify => Service['apache2']
  }

  file { '/var/www/html/.htaccess':
    ensure => file,
    source => 'puppet:///modules/apache2/www/htaccess'
  }

  file { '/var/www/html/index.html':
    ensure => file,
    content => template('apache2/index.html.erb')
  }

  exec { 'enable and disable apache mods':
    command     => 'a2enmod jk && a2enmod deflate && a2enmod ssl && a2ensite default-ssl && a2enmod rewrite',
    user        => 'root',
    subscribe   => [ Package['apache2'], Package['libapache2-mod-jk'] ],
    refreshonly => true,
    notify      => Service['apache2']
  }

  if ($ssl_use_letsencrypt == true) {

    # hack for mirebalais until we upgrade to a more recenty version of Ubuntu
    if ($site_domain == 'emr.hum.ht') {

      # instead of the apt-get install process (see below),
      # we manually installed cert-bot via this link:
      # https://gist.github.com/craigvantonder/6dcc3c9565b04a36f21d6cf6ffa106b4
      # also see: https://pihemr.atlassian.net/browse/UHM-4638

      # set up cron to renew certificates
      # note that the command is "certbot-auto" in this case
      cron { 'renew certificates':
        ensure  => present,
        command => 'certbot-auto renew --pre-hook "service apache2 stop" --post-hook "service apache2 start"',
        user    => 'root',
        hour    => 00,
        minute  => 00,
        environment => 'MAILTO=${sysadmin_email}',
      }

    }
    else {
      apt::ppa { 'ppa:certbot/certbot':
        options => "-y -k ${keyserver}"
      }

      package { 'software-properties-common':
        ensure => present
      }

      package { 'python-certbot-apache':
        ensure => present,
        require => [Apt::Ppa['ppa:certbot/certbot']]
      }

      # we need to generate the certs *before* we modify the default-ssl file
      exec { 'generate certificates':
        command => "certbot -n -m medinfo@pih.org --apache --agree-tos --domains ${site_domain} certonly",
        user    => 'root',
        require => [ Package['software-properties-common'], Package['python-certbot-apache'], Package['apache2'], File['/etc/apache2/sites-enabled/default-ssl.conf'] ],
        subscribe => Package['python-certbot-apache'],
        before => File['/etc/apache2/sites-available/default-ssl.conf'],
        notify => Service['apache2']
      }

      # set up cron to renew certificates
      cron { 'renew certificates':
        ensure  => present,
        command => 'certbot renew --pre-hook "service apache2 stop" --post-hook "service apache2 start"',
        user    => 'root',
        hour    => 00,
        minute  => 00,
        environment => 'MAILTO=${sysadmin_email}',
        require => [ Exec['generate certificates'] ]
      }
    }

  }
  else {
    file { "${ssl_cert_dir}/${ssl_cert_file}":
      ensure => file,
      source => "puppet:///modules/apache2/etc/ssl/certs/${ssl_cert_file}",
      notify => Service['apache2']
    }

    file { "${ssl_cert_dir}/${ssl_chain_file}":
      ensure => file,
      source => "puppet:///modules/apache2/etc/ssl/certs/${ssl_chain_file}",
      notify => Service['apache2']
    }

    file { "${ssl_key_dir}/${ssl_key_file}":
      ensure => present,
      notify => Service['apache2']
    }
  }

  service { 'apache2':
    ensure   => $services_ensure,
    enable   => $services_enable,
    require  => [ Package['apache2'], Package['libapache2-mod-jk'] ],
  }

  user { "$letsencrypt_user":
    ensure => 'present',
    password => "$letsencrypt_user_password",
    home => "/var/$letsencrypt_user",
    managehome => true,
    shell => '/bin/bash'
  }

  file { "/etc/letsencrypt" :
    ensure => directory,
    owner   => "$letsencrypt_user",
    group   => "root",
    require => User["$letsencrypt_user"]
  }

  file { "/etc/letsencrypt/live" :
    ensure => directory,
    owner   => "$letsencrypt_user",
    group   => "root",
    require => File["/etc/letsencrypt"]
  }

  file { "/etc/letsencrypt/live/$site_domain" :
    ensure => directory,
    owner   => "$letsencrypt_user",
    group   => "root",
    mode    => '0710',
    require => File["/etc/letsencrypt/live"]
  }

  file { "install-letsencrypt.sh":
    ensure  => present,
    path    => "/var/$letsencrypt_user/install-letsencrypt.sh",
    mode    => '0700',
    owner   => "$letsencrypt_user",
    group   => "$letsencrypt_user",
    content => template('apache2/install-letsencrypt.sh.erb'),
    require => User["$letsencrypt_user"]
  }

  exec { "add user to sudoers":
    command => "echo '$letsencrypt_user    ALL=(ALL) NOPASSWD: /usr/sbin/service apache2 restart' | sudo EDITOR='tee -a' visudo",
    require => User["$letsencrypt_user"]
  }

  exec { "download and from the git repo":
    command => "rm -rf /var/$letsencrypt_user/acme.sh && git clone https://github.com/acmesh-official/acme.sh.git /var/$letsencrypt_user/acme.sh",
    require => User["$letsencrypt_user"]
  }

  exec { "Initial letsencrypt install":
    command => "su $letsencrypt_user && cd /var/$letsencrypt_user/acme.sh && /bin/bash acme.sh --install",
    require => [User["$letsencrypt_user"], Exec['download and from the git repo']]
  }

  exec { "download and run install letsencrypt using $letsencrypt_user":
    command => "/var/$letsencrypt_user/install-letsencrypt.sh",
    require => [User["$letsencrypt_user"], Exec['Initial letsencrypt install']]
  }

  cron { "renew certificates using $letsencrypt_user user":
    ensure  => present,
    command => "'/var/$letsencrypt_user/.$letsencrypt_user.sh'/$letsencrypt_user.sh --cron --home '/var/$letsencrypt_user/.$letsencrypt_user.sh' > /dev/null",
    user    => "$letsencrypt_user",
    hour    => 23,
    minute  => 00,
    environment => 'MAILTO=${sysadmin_email}',
    require => User["$letsencrypt_user"]
  }

  # allows other modules to trigger an apache restart
  # there's an annoying tight dependency here we should fix
  exec { 'apache-restart':
    command     => "service apache2 restart",
    user        => 'root',
    refreshonly => true,
    subscribe => [ File["orderentry.zip"], File["labworkflow.zip"] ]
  }

}