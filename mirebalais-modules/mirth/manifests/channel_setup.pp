class mirth::channel_setup (
  $mirth_user = decrypt(hiera('mirth_user')),
  $mirth_password = decrypt(hiera('mirth_password')),
  $openmrs_db = hiera('openmrs_db'),
  $openmrs_db_user = decrypt(hiera('openmrs_db_user')),
  $openmrs_db_password = decrypt(hiera('openmrs_db_password')),
  $pacs_mirebalais_ip_address = hiera('pacs_mirebalais_ip_address'),
  $pacs_mirebalais_inbound_port = hiera('pacs_mirebalais_inbound_port'),
  $pacs_boston_ip_address = hiera('pacs_boston_ip_address'),
  $pacs_boston_inbound_port = hiera('pacs_boston_inbound_port'),
  $mirth_inbound_from_pacs_mirebalais_port = hiera('mirth_inbound_from_pacs_mirebalais_port'),
  $openmrs_mirebalais_inbound_port = hiera('openmrs_mirebalais_inbound_port')
) {

  exec { 'wait for mcservice':
    command     => 'sleep 5',
    subscribe   => Service['mcservice'],
    refreshonly => true
  }

  exec { 'create mirth user':
    cwd     => '/usr/local/mirthconnect',
    command => "echo 'user add ${mirth_user} ${mirth_password} mirth user PIH mogoodrich@pih.org' | /usr/local/mirthconnect/mccommand",
    require => Exec['wait for mcservice'],
    unless  => 'echo "user list" | /usr/local/mirthconnect/mccommand |grep mirth'
  }

  exec { 'stop all channels':
    cwd         => '/usr/local/mirthconnect',
    command     => "echo 'channel stop *' | /usr/local/mirthconnect/mccommand",
    require     => Exec['wait for mcservice'],
    subscribe   => [ File['/usr/local/mirthconnect/readHL7FromOpenmrsDatabaseChannel.xml'], File['/usr/local/mirthconnect/sendHL7ToPacsChannelMirebalais.xml'], File['/usr/local/mirthconnect/sendHL7ToPacsChannelBoston.xml'], File['/usr/local/mirthconnect/receiveHL7FromPacsChannelMirebalais.xml'] ],
    refreshonly => true
  }

  file { '/usr/local/mirthconnect/readHL7FromOpenmrsDatabaseChannel.xml':
    ensure  => present,
    content => template('mirth/readHL7FromOpenmrsDatabaseChannel.xml.erb'),
    require => File['/usr/local/mirthconnect']
  }

  file { '/usr/local/mirthconnect/sendHL7ToPacsChannelMirebalais.xml':
    ensure  => present,
    content => template('mirth/sendHL7ToPacsChannelMirebalais.xml.erb'),
    require => File['/usr/local/mirthconnect']
  }

  file { '/usr/local/mirthconnect/sendHL7ToPacsChannelBoston.xml':
    ensure  => present,
    content => template('mirth/sendHL7ToPacsChannelBoston.xml.erb'),
    require => File['/usr/local/mirthconnect']
  }

  file { '/usr/local/mirthconnect/receiveHL7FromPacsChannelMirebalais.xml':
    ensure => present,
    content => template('mirth/receiveHL7FromPacsChannelMirebalais.xml.erb'),
    require => File['/usr/local/mirthconnect']
  }

  exec { 'import read channel':
    cwd         => '/usr/local/mirthconnect',
    command     => "echo 'import /usr/local/mirthconnect/readHL7FromOpenmrsDatabaseChannel.xml force' | /usr/local/mirthconnect/mccommand",
    subscribe   => Exec['stop all channels'],
    refreshonly => true
  }

  exec { 'deploy read channel':
    cwd         => '/usr/local/mirthconnect',
    command     => "echo 'channel deploy \"Read HL7 From OpenMRS Database\"' | /usr/local/mirthconnect/mccommand",
    subscribe   => Exec['import read channel'],
    refreshonly => true
  }

  exec { 'import write channel 1':
    cwd         => '/usr/local/mirthconnect',
    command     => "echo 'import /usr/local/mirthconnect/sendHL7ToPacsChannelMirebalais.xml force' | /usr/local/mirthconnect/mccommand",
    subscribe   => Exec['stop all channels'],
    refreshonly => true
  }

  exec { 'deploy write channel 1':
    cwd         => '/usr/local/mirthconnect',
    command     => "echo 'channel deploy \"Send HL7 to PACS Mirebalais\"' | /usr/local/mirthconnect/mccommand",
    subscribe   => Exec['import write channel 1'],
    refreshonly => true
  }

  exec { 'import write channel 2':
    cwd         => '/usr/local/mirthconnect',
    command     => "echo 'import /usr/local/mirthconnect/sendHL7ToPacsChannelBoston.xml force' | /usr/local/mirthconnect/mccommand",
    subscribe   => Exec['stop all channels'],
    refreshonly => true
  }

  exec { 'deploy write channel 2':
    cwd         => '/usr/local/mirthconnect',
    command     => "echo 'channel deploy \"Send HL7 to Pacs Boston\"' | /usr/local/mirthconnect/mccommand",
    subscribe   => Exec['import write channel 2'],
    refreshonly => true
  }

  exec { 'import receive channel 1':
    cwd         => '/usr/local/mirthconnect',
    command     => "echo 'import /usr/local/mirthconnect/receiveHL7FromPacsChannelMirebalais.xml force' | /usr/local/mirthconnect/mccommand",
    subscribe   => Exec['stop all channels'],
    refreshonly => true
  }

  exec { 'deploy receive channel 1':
    cwd         => '/usr/local/mirthconnect',
    command     => "echo 'channel deploy \"Receive HL7 from PACS Mirebalais\"' | /usr/local/mirthconnect/mccommand",
    subscribe   => Exec['import receive channel 1'],
    refreshonly => true
  }

  exec { 'start all channels':
    cwd         => '/usr/local/mirthconnect',
    command     => "echo 'channel start *' | /usr/local/mirthconnect/mccommand",
    subscribe   => [ Exec['deploy read channel'], Exec['deploy write channel 1'], Exec['deploy write channel 2'], Exec['deploy receive channel 1'] ],
    refreshonly => true
  }
}
