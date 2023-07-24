class azcopy (
) {

  wget::fetch { 'azcopy-download':
    source      => 'https://aka.ms/downloadazcopy-v10-linux',
    destination => '/usr/local/azcopy.tar.gz',
    timeout     => 0,
    verbose     => false,
  }

  exec { 'azcopy-extract':
    cwd     => '/usr/local',
    command => 'tar -xf azcopy.tar.gz --strip-components=1',
    require => [ Wget::Fetch['azcopy-download'] ],
  }

  file { '/usr/local/sbin/azcopy':
    source  => '/usr/local/azcopy',
    path    => '/usr/local/sbin/azcopy',
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    require => [ Exec['azcopy-extract'] ]
  }

}