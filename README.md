# rhn_register puppet module

## Overview

Registers a machine with RHN or a satellite server.  If a machine
is already registered then nothing happens, unless the force 
parameter is set to true.

### class rhn_register

Parameters:

* profilename - The name the system should use in RHN or Satellite
* username - The username to use when registering the system
* password - The password to use when registering the system
* activationkey - The activation key to use when registering the system (cannot be used with username and password)
* hardware - Whether or not the hardware information should be probed (default: true)
* packages - Whether or not packages information should be probed (default: true)
* virtinfo - Whether or not virtualiztion information should be uploaded (default: true)
* rhnsd - Whether or not rhnsd should be started after registering (default: true)
* force - Should the registration be forced.  Use this option with caution, setting it to true will cause the rhnreg_ks command to be run every time puppet runs (default: false)
* proxy - If needed, specify the HTTP Proxy
* proxyuser - Username to use for the proxy server
* proxypass - Password to use for the proxy server
* sslca - Path to the SSL CA to use.  If needed, it usually looks like /usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT
* serverurl - URL to register with

Examples: 

    class { 'rhn_register':
      sslca         => '/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT',
      serverurl     => 'https://my-satellite-server.example.com/XMLRPC',
      activationkey => '1-activationkeyiwanttouse',
    }

    class { 'rhn_register':
      activationkey => '1-activationkeyiwanttouseforrhn',
    }

## Supported Platforms

This class has only been tested on RHEL6.
