# == Class: rhn_register
class rhn_register (
  Boolean           $use_classic    = true,
  Optional[String]  $profilename    = undef,
  Optional[String]  $username       = undef,
  Optional[String]  $password       = undef,
  Optional[String]  $activationkey  = undef,
  Boolean           $hardware       = true,
  Boolean           $packages       = true,
  Boolean           $virtinfo       = true,
  Boolean           $rhnsd          = true,
  Boolean           $force          = false,
  Optional[String]  $proxy          = undef,
  Optional[String]  $proxyuser      = undef,
  Optional[String]  $proxypass      = undef,
  Optional[String]  $sslca          = undef,
  Optional[String]  $serverurl      = undef,
  Boolean           $insecure       = false,
  Optional[String]  $base_url       = undef,
  Optional[String]  $unit_type      = undef,
  Optional[String]  $system_name    = undef,
  Optional[String]  $consumer_id    = undef,
  Optional[String]  $org            = undef,
  Optional[String]  $release        = undef,
  Boolean           $auto_attach    = true,
  Boolean           $auto_subscribe = false,
  Optional[String]  $service_level  = undef,
  Optional[String]  $environment    = undef,
) {

  if $facts['os']['family'] != 'RedHat' {
    fail("You can't register ${facts['os']['name']} with RHN or Satellite using this puppet module")
  }

  if $rhn_register::username == undef and $rhn_register::activationkey == undef or $activationkey == [] {
    fail('Either an activation key or username/password is required to register')
  }

  if $use_classic {
    $command = '/usr/sbin/rhnreg_ks'
    $creates_file = '/etc/sysconfig/rhn/systemid'

    $arguments = {
      'profilename'   => $rhn_register::profilename,
      'activationkey' => $rhn_register::activationkey,
      'username'      => $rhn_register::username,
      'password'      => $rhn_register::password,
      'nohardware'    => !$rhn_register::hardware,
      'nopackages'    => !$rhn_register::packages,
      'novirtinfo'    => !$rhn_register::virtinfo,
      'norhnsd'       => !$rhn_register::rhnsd,
      'proxyUser'     => $rhn_register::proxyuser,
      'proxyPassword' => $rhn_register::proxypass,
      'proxy'         => $rhn_register::proxy,
      'sslCACert'     => $rhn_register::sslca,
      'serverUrl'     => $rhn_register::serverurl,
    }

  } elsif !$use_classic {
    $command = '/usr/bin/subscription-manager register'
    $creates_file = '/etc/pki/consumer/cert.pem'

    $arguments = {
      'name'          => $rhn_register::system_name,
      'username'      => $rhn_register::username,
      'password'      => $rhn_register::password,
      'activationkey' => $rhn_register::activationkey,
      'serverurl'     => $rhn_register::serverurl,
      'proxy'         => $rhn_register::proxy,
      'proxyuser'     => $rhn_register::proxyuser,
      'proxypassword' => $rhn_register::proxypass,
      'insecure'      => $rhn_register::insecure,
      'baseurl'       => $rhn_register::base_url,
      'typeid'        => $rhn_register::unit_type,
      'consumerid'    => $rhn_register::consumer_id,
      'org'           => $rhn_register::org,
      'environment'   => $rhn_register::environment,
      'release'       => $rhn_register::release,
      'auto-attach'   => $rhn_register::auto_attach,
      'autosubscribe' => $rhn_register::auto_subscribe,
      'servicelevel'  => $rhn_register::service_level,
    }

  }

  $final_args = $arguments.filter |$key, $val| { $val =~ NotUndef }
  $command_flags = command_args($final_args)

  if $rhn_register::force {
    exec { 'register_with_rhn':
      command => "${command} --force ${command_flags}",
    }
  } else {
    exec { 'register_with_rhn':
      command => "${command} ${command_flags}",
      creates => $creates_file,
    }
  }
}
