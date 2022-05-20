class openmrs::initial_setup(
  $openmrs_db = hiera('openmrs_db'),
  $openmrs_db_user = decrypt(hiera('openmrs_db_user')),
  $openmrs_db_password = decrypt(hiera('openmrs_db_password')),
  $tomcat = hiera('tomcat'),
  $webapp_name = hiera('webapp_name'),
  $package_name = hiera('package_name')
) {

  mysql_database { $openmrs_db :
    ensure  => present,
    require => [Service['mysqld'],  Package[$package_name]],
    charset => 'utf8',
  }

  mysql_user { "${openmrs_db_user}@localhost":
    ensure        => present,
    password_hash => mysql_password($openmrs_db_password),
    require => [ Service['mysqld'], Package[$package_name]],
  }

  mysql_grant { "${openmrs_db_user}@localhost/${openmrs_db}":
    options    => ['GRANT'],
    privileges => ['ALL'],
    table => '*.*',
    user => "${openmrs_db_user}@localhost",
    require => [ Service['mysqld'],  Package[$package_name]],
  }

  mysql_grant { "root@localhost/${openmrs_db}":
    options    => ['GRANT'],
    privileges => ['ALL'],
    table => '*.*',
    user => "root@localhost",
    require => [Service['mysqld'],  Package[$package_name]],
    notify  => Exec['set up base schema'];
  }

  file { '/usr/local/liquibase.jar':
    ensure => present,
    source => 'puppet:///modules/openmrs/liquibase-core-4.4.3.jar'
  }

  file { "/usr/local/table-exists.sh":
    ensure  => present,
    content => template('openmrs/table-exists.sh.erb'),
    owner   => $tomcat,
    group   => $tomcat,
    mode    => '0700',
    require => File["/usr/local/liquibase.jar"]
  }

  file { "/usr/local/table-has-data.sh":
    ensure  => present,
    content => template('openmrs/table-has-data.sh.erb'),
    owner   => $tomcat,
    group   => $tomcat,
    mode    => '0700',
    require => File["/usr/local/liquibase.jar"]
  }

  exec { 'set up base schema':
    cwd         =>  '/usr/local/',
    command     => "java -Dliquibase.databaseChangeLogTableName=liquibasechangelog -Dliquibase.databaseChangeLogLockTableName=liquibasechangeloglock -jar liquibase.jar --driver=com.mysql.jdbc.Driver --classpath=/var/lib/${tomcat}/webapps/${webapp_name}.war --url=jdbc:mysql://localhost:3306/${openmrs_db} --changeLogFile=liquibase-schema-only.xml --username=${openmrs_db_user} --password='${openmrs_db_password}' update",
    user        => 'root',
    unless      => "/usr/local/table-exists.sh ${openmrs_db_user} ${openmrs_db_password} ${openmrs_db} patient",
    refreshonly => true,
    require     => [ File['/usr/local/liquibase.jar'], File['/usr/local/table-exists.sh'], Package[$package_name] ],
    timeout     => 0,
    notify      => Exec['set up core data']
  }

  exec { 'set up core data':
    cwd         =>  '/usr/local/',
    command     => "java -Dliquibase.databaseChangeLogTableName=liquibasechangelog -Dliquibase.databaseChangeLogLockTableName=liquibasechangeloglock -jar liquibase.jar --driver=com.mysql.jdbc.Driver --classpath=/var/lib/${tomcat}/webapps/${webapp_name}.war --url=jdbc:mysql://localhost:3306/${openmrs_db} --changeLogFile=liquibase-core-data.xml --username=${openmrs_db_user} --password='${openmrs_db_password}' update",
    user        => 'root',
    unless      => "/usr/local/table-has-data.sh ${openmrs_db_user} ${openmrs_db_password} ${openmrs_db} patient",
    refreshonly => true,
    require     => [ File['/usr/local/liquibase.jar'], File['/usr/local/table-has-data.sh'], Package[$package_name] ],
    timeout     => 0,
    notify      => Exec['tomcat-restart']
  }

  # hack to let us remote the mirebalais metadata module from the build; can be removed after it has been removed from all servers
  exec { 'make mirebalais metadata module not mandatory - error running this command can be ignored when provisioning new server':
    command     => "mysql -u${openmrs_db_user} -p'${openmrs_db_password}' ${openmrs_db} -e 'update ${openmrs_db}.global_property set property_value=\"false\" where property=\"mirebalaismetadata.mandatory\"'",
    user        => 'root',
    require => Package[$package_name],
  }

}
