class docker (
  $docker_repo = hiera('docker_repo'),
  $docker_compose_version = hiera('docker_compose_version')
) {

  include base_packages

  exec { "docker_key":
    command      => "/usr/bin/curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
    require => Package['curl']
  }

  exec { "docker_repo":
    command      => "/usr/bin/add-apt-repository '$docker_repo'",
    require       => Exec['docker_key']
  }

  exec { "docker_cache_policy":
    command      => "/usr/bin/apt-cache policy docker-ce",
    require       => Exec['docker_repo']
  }

  # Dependent packages are installed in base_packages module
  package { 'docker-ce':
    ensure => installed,
    require => [ Package['apt-transport-https'], Package['curl'], Package['software-properties-common'], Package['ca-certificates'], Exec['docker_cache_policy'] ]
  }

  ##### docker-compose
  exec { "delete_docker_compose_repo":
    command      => 'rm -rf /usr/local/bin/docker-compose',
  }

  exec { "docker_compose_repo":
    command      => "curl -L 'https://github.com/docker/compose/releases/download/${docker_compose_version}/docker-compose-Linux-x86_64' -o /usr/local/bin/docker-compose",
    require => Exec[delete_docker_compose_repo]
  }

  exec { "install_docker_compose":
    command      => 'chmod +x /usr/local/bin/docker-compose',
    require       => [Exec[delete_docker_compose_repo], Exec['docker_compose_repo']]
  }

}