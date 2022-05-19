class openmrs::initial_setup(
  $openmrs_db = hiera('openmrs_db'),
  $openmrs_db_user = decrypt(hiera('openmrs_db_user')),
  $openmrs_db_password = decrypt(hiera('openmrs_db_password')),
  $tomcat = hiera('tomcat'),
  $package_name = hiera('package_name')
) {

  mysql_database { $openmrs_db :
    ensure  => present,
    require => [Service['mysqld'],  Package[$package_name]],
    charset => 'utf8',
  } ->

  mysql_user { "${openmrs_db_user}@localhost":
    ensure        => present,
    password_hash => mysql_password($openmrs_db_password),
    require => [ Service['mysqld'], Package[$package_name]],
  } ->

  mysql_grant { "${openmrs_db_user}@localhost/${openmrs_db}":
    options    => ['GRANT'],
    privileges => ['ALL'],
    table => '*.*',
    user => "${openmrs_db_user}@localhost",
    require => [ Service['mysqld'],  Package[$package_name]],
  } ->

  mysql_grant { "root@localhost/${openmrs_db}":
    options    => ['GRANT'],
    privileges => ['ALL'],
    table => '*.*',
    user => "root@localhost",
    require => [Service['mysqld'],  Package[$package_name]],
    notify  => Openmrs::Liquibase_migrate['set up base schema'];
  }

  file { '/usr/local/liquibase.jar':
    ensure => present,
    source => 'puppet:///modules/openmrs/liquibase-core-4.4.3.jar'
  }


  openmrs::liquibase_migrate { 'set up base schema':
    dataset => 'liquibase-schema-only.xml',
    unless  => "mysql -u${openmrs_db_user} -p'${openmrs_db_password}' ${openmrs_db} -e 'desc patient'",
    refreshonly => true,
    notify  => Openmrs::Liquibase_migrate['set up core data']
  }

  openmrs::liquibase_migrate { 'set up core data':
    dataset     => 'liquibase-core-data.xml',
    refreshonly => true
  }

 /* openmrs::liquibase_migrate { 'migrate update to latest':
    dataset     => 'liquibase-update-to-latest.xml',
    refreshonly => true
  }*/

  # hack to let us remote the mirebalais metadata module from the build; can be removed after it has been removed from all servers
  exec { 'make mirebalais metadata module not mandatory - error running this command can be ignored when provisioning new server':
    command     => "mysql -u${openmrs_db_user} -p'${openmrs_db_password}' ${openmrs_db} -e 'update ${openmrs_db}.global_property set property_value=\"false\" where property=\"mirebalaismetadata.mandatory\"'",
    user        => 'root',
    require => Package[$package_name],
  }

  exec { 'tomcat-start':
    command     => "service ${tomcat} restart",
    user        => 'root',
    subscribe   => Openmrs::Liquibase_migrate['set up core data'],
    refreshonly => true
  }
}
