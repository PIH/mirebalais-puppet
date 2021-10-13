class mail (
	$smtp_username = decrypt(hiera('smtp_username')),
	$smtp_userpassword = decrypt(hiera('smtp_userpassword'))
){

	package { 'sendmail':
		ensure => installed,
	}

	package { 'mailutils':
		ensure => installed,
    		require => [ Package['sendmail'] ]
	}

	file { "/etc/mail/authinfo":
		ensure  => directory,
		owner   => root,
		group   => smmsp,
		mode    => '0700',
		require =>  Package['sendmail']
	}

	file { '/etc/mail/authinfo/smtp-auth':
		ensure  => file,
		group   => smmsp,
		mode    => '0644',
		content => template('mail/smtp-auth.erb'),
		require => Package['sendmail']
	}

	exec { 'authentication_hash_db_map':
		command => "/bin/bash -c 'cd /etc/mail/authinfo; sudo makemap hash smtp-auth < smtp-auth'",
		user => 'root',
		require => Package['sendmail']
	}

	file { '/etc/mail/sendmail.mc':
	    	ensure  => file,
    		group   => smmsp,
    		mode    => '0644',
	    	content => template('mail/sendmail.mc.erb'),
	    	require => Package['sendmail']
	}

	exec { 'rebuild_sendmail_config':
		command => "/bin/bash -c 'cd /etc/mail; make'",
		user => 'root',
		require => Package['sendmail']
	}

	exec { 'sendmail-restart':
		command     => "/etc/init.d/sendmail restart",
		user        => 'root'
	}
}
