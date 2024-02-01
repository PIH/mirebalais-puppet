class commcare_sync(
  $commcare_sync_user = "commcare_sync",
  $commcare_sync_home_dir = "/home/${commcare_sync_user}",
  $commcare_sync_code_dir = "${commcare_sync_home_dir}/code",
  $commcare_sync_github_url = "https://github.com/dimagi/commcare-sync.git",
) {

    user { "${commcare_sync_user}":
        ensure => "present",
        home   => "${commcare_sync_home_dir}",
        groups => "docker",
        shell  => "/bin/bash"
    }

    file { "${commcare_sync_home_dir}":
        ensure  => directory,
        owner   => "${commcare_sync_user}",
        group   => "${commcare_sync_user}",
        mode    => "0755",
        require => User["${commcare_sync_user}"]
    }

    vcsrepo { "${commcare_sync_code_dir}":
        provider => git,
        source   => "${commcare_sync_github_url}",
        ensure   => latest,
        require => File["${commcare_sync_home_dir}"]
    }

    file { "${commcare_sync_home_dir}/.commcare_sync.env":
        ensure  => present,
        path    => "${commcare_sync_home_dir}/.commcare_sync.env",
        mode    => "0700",
        owner   => "${commcare_sync_user}",
        group   => "${commcare_sync_user}",
        content => template('commcare_sync/commcare_sync.env.erb'),
        require => File["${commcare_sync_home_dir}"]
    }

    file { "${commcare_sync_home_dir}/setup.sh":
      ensure => present,
      source => "puppet:///modules/commcare_sync/setup.sh",
      path    => "${commcare_sync_home_dir}/setup.sh",
      mode    => "0700",
      owner   => "${commcare_sync_user}",
      group   => "${commcare_sync_user}",
      require => File["${commcare_sync_home_dir}/.commcare_sync.env"]
    }

    exec { "${commcare_sync_home_dir}/setup.sh":
        command => "bash setup.sh ${commcare_sync_code_dir}",
        cwd   => "${commcare_sync_home_dir}",
        require => File["${commcare_sync_home_dir}/setup.sh"]
    }
}
