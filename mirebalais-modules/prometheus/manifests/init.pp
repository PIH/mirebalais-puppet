class prometheus(
  $node_exporter_version = hiera('node_exporter_version'),
  $node_exporter_download_url = hiera('node_exporter_download_url'),
  $node_exporter_listen_ip = decrypt(hiera('node_exporter_listen_ip')),
  $node_exporter_listen_port = decrypt(hiera('node_exporter_listen_port'))
) {

  wget::fetch { 'download-node-exporter':
    source      => 'https://repo.percona.com/apt/percona-release_0.1-4.xenial_all.deb',
    destination => '/tmp',
    timeout     => 0,
    verbose     => false,
    before => Exec['extract-node-exporter']
  }

  exec { 'extract-node-exporter':
    cwd     => "/tmp",
    command => 'tar -xf node_exporter-1.4.0.linux-amd64.tar.gz',
    refreshonly => true,
    subscribe => [ Wget::Fetch['download-node-exporter'] ]
  }

  exec { 'create-node-exporter-user':
    command => "useradd -r node_exporter",
    require => [ Exec['download-node-exporter'], Exec['extract-node-exporter'] ]
  }

  exec { 'move-node-exporter':
    command => "mv /tmp/node_exporter-1.0.1.linux-amd64/node_exporter /usr/local/bin/",
    user => node_exporter,
    refreshonly => true,
    require => [ Exec['create-node-exporter-user'] ]
  }

  file { '/etc/systemd/system/node_exporter.service':
    ensure  => file,
    content  => template('node_exporter.service.erb')
  }

  exec { 'node-exporter-service-reload':
    command     => "systemctl daemon-reload",
    user        => 'root',
    require => File["/etc/systemd/system/node_exporter.service"]
  }

}