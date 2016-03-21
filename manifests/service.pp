# See README.md for usage information
class sssd::service (
  $sssd_service     = $sssd::sssd_service,
  $mkhomedir        = $sssd::mkhomedir,
  $manage_oddjobd   = $sssd::manage_oddjobd,
  $service_ensure   = $sssd::service_ensure,
  $service_provider = $sssd::service_provider,
) {
  service { $sssd_service:
    ensure     => $service_ensure,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    provider   => $sssd::service_provider,
  }

  if $mkhomedir and $manage_oddjobd {

    service { 'oddjobd':
      ensure     => $service_ensure,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
      provider   => $sssd::service_provider,
      require    => Service[$sssd_service],
    }

  }

}
