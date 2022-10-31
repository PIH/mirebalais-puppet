class prometheus(
  $node_exporter_version = hiera('node_exporter_version'),
  $node_exporter_download_url = hiera('node_exporter_download_url'),
  $node_exporter_listen_ip = decrypt(hiera('node_exporter_listen_ip')),
  $node_exporter_listen_port = decrypt(hiera('node_exporter_listen_port'))
) {

  exec { 'create-node-exporter-user':
    command => "useradd -r node_exporter || true",
  }

  wget::fetch { 'download-node-exporter':
    source      => "$node_exporter_download_url",
    destination => "/tmp/node_exporter$node_exporter_version"
  }

  exec { 'extract-node-exporter':
    command => "tar -xvf /tmp/node_exporter$node_exporter_version",
    unless  => "/bin/ls -ap /tmp | grep node_exporter$node_exporter_version | grep -v grep",
    require => [ Wget::Fetch['download-node-exporter'] ]
  }

  exec { 'move-node-exporter':
    command => "mv /tmp/node_exporter-$node_exporter_version.linux-amd64/node_exporter /usr/local/bin/",
    user => node_exporter,
    refreshonly => true,
    require => [  Exec['create-node-exporter-user'] ]
  }

  file { '/etc/systemd/system/node_exporter.service':
    ensure  => file,
    content  => template('prometheus/node_exporter.service.erb'),
    require => [ Wget::Fetch['download-node-exporter'], Exec['extract-node-exporter'], Exec['create-node-exporter-user'] ]
  }

  exec { 'node-exporter-service-reload':
    command     => "systemctl daemon-reload",
    user        => 'root',
    require => File["/etc/systemd/system/node_exporter.service"]
  }

}