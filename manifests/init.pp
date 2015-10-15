# == Class: rhn_register
#
# This class registers a machine with RHN or a Satellite Server.  If a machine
# is already registered it does nothing unless the force parameter is set to true.
#
# === Parameters:
#
# The class supports nearly all of the parameters supported by rhnreg_ks
#
#   [*profilename*]
#     The name the system should use in RHN or Satellite
#   [*username*]
#     The username to use when registering the system
#   [*password*]
#     The password to use when registering the system
#   [*activationkey*]
#     The activation key to use when registering the system (cannot be used with
#     username and password) - This is the recommended way so that credentials
#     aren't stored in reports.
#   [*hardware*]
#     Whether or not the hardware information should be probed (default: true)
#   [*packages*]
#     Whether or not packages information should be probed (default: true)
#   [*virtinfo*]
#     Whether or not virtualiztion information should be uploaded (default: true)
#   [*rhnsd*]
#     Whether or not rhnsd should be started after registering (default: true)
#   [*force*]
#     Should the registration be forced.  Use this option with caution, setting it
#     to true will cause the rhnreg_ks command to be run every time puppet runs
#     (default: false)
#   [*proxy*]
#     If needed, specify the HTTP Proxy
#   [*proxyuser*]
#     Username to use for the proxy server
#   [*proxypass*]
#     Password to use for the proxy server
#   [*sslca*]
#     Path to the SSL CA to use.  If needed, it usually looks like
#     /usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT
#   [*serverurl*]
#     URL to the server to register with
#
# === Examples
#
# class { 'rhn_register':
#    sslca         => '/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT',
#    serverurl     => 'https://my-satellite-server.example.com/XMLRPC',
#    activationkey => '1-activationkeyiwanttouse',
# }
#
# class { 'rhn_register':
#    activationkey => '1-activationkeyiwanttouseforrhn',
# }
#
# === Authors
#
# Phil Fenstermacher <pcfens@wm.edu>
#
class rhn_register (
  $profilename   = undef,
  $username      = undef,
  $password      = undef,
  $activationkey = undef,
  $hardware      = true,
  $packages      = true,
  $virtinfo      = true,
  $rhnsd         = true,
  $force         = false,
  $proxy         = undef,
  $proxyuser     = undef,
  $proxypass     = undef,
  $sslca         = undef,
  $serverurl     = undef,

  $use_classic   = false,
  $insecure      = false,
  $base_url      = undef,
  $type          = undef,
  $name          = undef,
  $consumer_id   = undef,
  $org           = undef,
  $release       = undef,
  $auto_attach   = true,
  $service_level = undef
){
  if $::osfamily != 'RedHat' {
    fail("You can't register ${::operatingsystem} with RHN or Satellite using this puppet module")
  }

  if $rhn_register::username == undef and $rhn_register::activationkey == undef or $activationkey == [] {
    fail('Either an activation key or username/password is required to register')
  }

  if $use_classic {
    $command = '/usr/sbin/rhnreg_ks'

    $arguments = {
      'profilename'   => $rhn_register::profilename,
      'activationkey' => $rhn_register::activationkey,
      'username'      => $rhn_register::username,
      'password'      => $rhn_register::password,
      'nohardware'    => !$hardware,
      'nopackages'    => !$packages,
      'novirtinfo'    => !$virtinfo,
      'norhnsd'       => !$rhnsd,
      'proxyUser'     => $rhn_register::proxyuser,
      'proxyPassword' => $rhn_register::proxypass,
      'proxy'         => $rhn_register::proxy,
      'sslCACert'     => $rhn_register::sslca,
      'serverUrl'     => $rhn_register::serverurl,
    }

  } elsif !$use_classic {
    $command = 'subscription-manager register'

    $arguments = {
      'name'          => $rhn_register::name,
      'proxyuser'     => $rhn_register::proxyuser,
      'proxypassword' => $rhn_register::proxypass,
      'insecure'      => $rhn_register::insecure,
      'baseurl'       => $rhn_register::base_url,
      'typeid'        => $rhn_register::type,
      'consumerid'    => $rhn_register::consumer_id,
      'org'           => $rhn_register::org,
      'environment'   => $rhn_register::environment,
      'release'       => $rhn_register::release,
      'auto-attach'   => $rhn_register::auto_attach,
      'servicelevel'  => $rhn_register::service_level,
    }

  }

  $final_args = delete_undef_values($arguments)
  $command_args = command_args($final_args)

  if $rhn_register::force {
    exec { 'register_with_rhn':
      command => "${command} --force ${rhn_register::command_args}",
    }
  } else {
    exec { 'register_with_rhn':
      command => "${command}${rhn_register::command_args}",
      creates => '/etc/sysconfig/rhn/systemid',
    }
  }
}
