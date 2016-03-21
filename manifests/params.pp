# Default parameters
class sssd::params {

  $ensure = 'present'
  $config = {
    'sssd' => {
      'config_file_version' => '2',
      'services'            => 'nss, pam',
      'domains'             => 'ad.example.com',
    },
    'domain/ad.example.com' => {
      'id_provider'       => 'ad',
      'krb5_realm'        => 'AD.EXAMPLE.COM',
      'cache_credentials' => true,
    },
  }
  $enable_mkhomedir_flags  = ['--enablesssd', '--enablesssdauth', '--enablemkhomedir']
  $disable_mkhomedir_flags = ['--enablesssd', '--enablesssdauth', '--disablemkhomedir']

  case $::osfamily {

    'RedHat': {

      $sssd_package   = 'sssd'
      $sssd_service   = 'sssd'
      $service_ensure = 'running'
      $config_file    = '/etc/sssd/sssd.conf'
      $mkhomedir      = true

      if versioncmp($::operatingsystemrelease, '6.0') < 0 {
        $extra_packages = [
          'authconfig',
        ]
        $extra_packages_ensure = 'latest'
        $manage_oddjobd        = false
      } else {
        $extra_packages = [
          'authconfig',
          'oddjob-mkhomedir',
        ]
        $extra_packages_ensure = 'present'
        $manage_oddjobd        = true
      }

    }

    'Debian': {

      $sssd_package   = 'sssd'
      $sssd_service   = 'sssd'
      $service_ensure = 'running'
      $config_file    = '/etc/sssd/sssd.conf'
      $mkhomedir      = true
      $extra_packages = [
        'libpam-runtime',
        'libpam-sss',
        'libnss-sss',
      ]
      $extra_packages_ensure = 'present'
      $manage_oddjobd        = false

      case $::operatingsystem {
        'Ubuntu' : {
          if (versioncmp($::operatingsystemrelease, '15.04') >= 0) {
            $service_provider = 'systemd'
          } else {
            $service_provider = 'upstart'
          }
        }
        default: {
          if (versioncmp($::operatingsystemmajrelease, '8') >= 0) {
            $service_provider = 'systemd'
          }
        }
      }

    }

    default: {
      fail("Unsupported osfamily: ${::osfamily}")
    }

  }

}
