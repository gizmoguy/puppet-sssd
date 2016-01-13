# See README.md for usage information
class sssd::config (
  $ensure                  = $sssd::ensure,
  $config                  = $sssd::config,
  $config_file             = $sssd::config_file,
  $mkhomedir               = $sssd::mkhomedir,
  $enable_mkhomedir_flags  = $sssd::enable_mkhomedir_flags,
  $disable_mkhomedir_flags = $sssd::disable_mkhomedir_flags,
) {

  file { 'sssd.conf':
    ensure  => $ensure,
    path    => $config_file,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => template("${module_name}/sssd.conf.erb"),
  }

  case $::osfamily {

    'Redhat': {

      $authconfig_flags = $mkhomedir ? {
        true  => join($enable_mkhomedir_flags, ' '),
        false => join($disable_mkhomedir_flags, ' '),
      }
      $authconfig_update_cmd = "/usr/sbin/authconfig ${authconfig_flags} --update"
      $authconfig_test_cmd   = "/usr/sbin/authconfig ${authconfig_flags} --test"
      $authconfig_check_cmd  = "/usr/bin/test \"`${authconfig_test_cmd}`\" = \"`/usr/sbin/authconfig --test`\""

      exec { 'authconfig-mkhomedir':
        command => $authconfig_update_cmd,
        unless  => $authconfig_check_cmd,
      }

    }

    'Debian': {

      if $mkhomedir {

        exec { 'pam-auth-update':
          path        => '/bin:/usr/bin:/sbin:/usr/sbin',
          refreshonly => true,
        }

        file { '/usr/share/pam-configs/pam_mkhomedir':
          ensure => file,
          owner  => 'root',
          group  => 'root',
          mode   => '0644',
          source => "puppet:///modules/${module_name}/pam_mkhomedir",
          notify => Exec['pam-auth-update'],
        }

      }

      if $::operatingsystem == 'Ubuntu' and $::lsbdistcodename == 'wily' {
        # We need to update apparmor config to workaround a bug
        file { '/etc/apparmor.d/usr.sbin.sssd':
          ensure  => file,
          content => template("${module_name}/usr.sbin.sssd.erb"),
        }
      }

    }

    default: { }

  }

}
