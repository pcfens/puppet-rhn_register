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
class rhn_register(
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
){
  if $::osfamily != 'RedHat' and $::operatingsystem != 'Solaris' {
    fail("You can't register ${::operatingsystem} with RHN or Satellite using this puppet module")
  }

  if $rhn_register::username == undef and $rhn_register::activationkey == undef {
    fail('Either an activation key or username/password is required to register')
  }

  $profile_name = $rhn_register::profilename ? {
    undef   => '',
    default => " --profilename ${rhn_register::profilename}",
  }

  $rhn_login = $rhn_register::username ? {
    undef   => '',
    default => " --username ${rhn_register::username} --password ${rhn_register::password}",
  }

  $activation_key = $rhn_register::activationkey ? {
    undef   => '',
    default => " --activationkey ${rhn_register::activationkey}",
  }

  $send_hardware = $rhn_register::hardware ? {
    false   => ' --nohardware',
    default => '',
  }

  $send_packages = $rhn_register::packages ? {
    false   => ' --nopackages',
    default => '',
  }

  $send_virtinfo = $rhn_register::virtinfo ? {
    false   => ' --novirtinfo',
    default => '',
  }

  $start_rhnsd = $rhn_register::rhnsd ? {
    false   => ' --norhnsd',
    default => '',
  }

  $proxy_login = $rhn_register::proxyuser ? {
    undef   => '',
    default => " --proxyUser ${rhn_register::proxyuser} --proxyPassword ${rhn_register::proxypass}",
  }

  $proxy_server = $rhn_register::proxy ? {
    undef   => '',
    default => " --proxy ${rhn_register::proxy}",
  }

  $ssl_ca = $rhn_register::sslca ? {
    undef   => '',
    default => " --sslCACert ${rhn_register::sslca}",
  }

  $server_url = $rhn_register::serverurl ? {
    undef   => '',
    default => " --serverUrl ${rhn_register::serverurl}",
  }

  $command_args = "${rhn_register::profile_name}${rhn_register::activation_key}${rhn_register::rhn_login}${rhn_register::send_hardware}${rhn_register::send_packages}${rhn_register::send_virtinfo}${rhn_register::start_rhnsd}${rhn_register::proxy_server}${rhn_register::proxy_login}${rhn_register::ssl_ca}${rhn_register::server_url}"

  if $rhn_register::force {
    exec { 'register_with_rhn':
      command => "/usr/sbin/rhnreg_ks --force${rhn_register::command_args}",
    }
  } else {
    exec { 'register_with_rhn':
      command => "/usr/sbin/rhnreg_ks${rhn_register::command_args}",
      creates => '/etc/sysconfig/rhn/systemid',
    }
  }
}
