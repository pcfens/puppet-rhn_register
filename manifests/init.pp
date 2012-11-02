class rhn_register(
  $profilename = 'undef',
  $username = 'undef',
  $password = 'undef',
  $activationkey = 'undef',
  $hardware = true,
  $packages = true,
  $virtinfo = true,
  $rhnsd = true,
  $force = false,
  $proxy = 'undef',
  $proxyuser = 'undef',
  $proxypass = 'undef',
  $sslca = 'undef',
  $serverurl = 'undef',
){
  if $::operatingsystem != 'RedHat' and $::operatingsystem != 'Solaris' {
    fail("You can't register ${::operatingsystem} with RHN or Satellite using this puppet module")
  }

  if $rhn_register::username == 'undef' and $rhn_register::activationkey == 'undef' {
    fail('Either an activation key or username/password is required to register')
  }

  $profile_name = $rhn_register::profilename ? {
    'undef' => '',
    default => "--profilename ${rhn_register::profilename}",
  }

  $rhn_login = $rhn_register::username ? {
    'undef' => '',
    default => "--username ${rhn_register::username} --password ${rhn_register::password}",
  }

  $activation_key = $rhn_register::activationkey ? {
    'undef' => '',
    default => "--activationkey ${rhn_register::activationkey}",
  }

  $send_hardware = $rhn_register::hardware ? {
    false   => '--nohardware',
    default => '',
  }

  $send_packages = $rhn_register::packages ? {
    false   => '--nopackages',
    default => '',
  }

  $send_virtinfo = $rhn_register::virtinfo ? {
    false   => '--novirtinfo',
    default => '',
  }

  $start_rhnsd = $rhn_register::rhnsd ? {
    false   => '--norhnsd',
    default => '',
  }

  $proxy_login = $rhn_register::proxyuser ? {
    'undef' => '',
    default => "--proxyUser ${rhn_register::proxyuser} --proxyPassword ${rhn_register::proxypass}",
  }

  $proxy_server = $rhn_register::proxy ? {
    'undef' => '',
    default => "--proxy ${rhn_register::proxy}",
  }

  $ssl_ca = $rhn_register::sslca ? {
    'undef' => '',
    default => "--sslCACert ${rhn_register::sslca}",
  }

  $server_url = $rhn_register::serverurl ? {
    'undef' => '',
    default => "--serverUrl ${rhn_register::serverurl}",
  }

  $command_args = "${rhn_register::profile_name} ${rhn_register::activation_key} ${rhn_register::rhn_login} ${rhn_register::send_hardware} ${rhn_register::send_packages} ${rhn_register::send_virtinfo} ${rhn_register::start_rhnsd} ${rhn_register::proxy_server} ${rhn_register::proxy_login} ${rhn_register::ssl_ca} ${rhn_register::server_url}"

  if $rhn_register::force {
    exec { 'register_with_rhn':
      command => "/usr/sbin/rhnreg_ks --force ${rhn_register::command_args}",
    }
  }

  exec { 'register_with_rhn':
    command => "/usr/sbin/rhnreg_ks ${rhn_register::command_args}",
    creates => '/etc/sysconfig/rhn/systemid',
  }
}
