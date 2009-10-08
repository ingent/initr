class apache {

  #TODO: better way to know if node includes Nagios class?
  if $nagios_proxytunnel == "0" or $nagios_proxytunnel == "1" {
    include apache::nagios
  }

  package { $httpd:
    ensure => installed,
  }

  service { $httpd_service:
    ensure => running,
    enable => true,
    require => Package[$httpd],
  }

  # debian a2enmod, but just one symlink
  define enmod() {
    file { "/etc/apache2/mods-enabled/$name":
      ensure => "../mods-available/$name",
      notify => Service[$httpd_service];
    }
  }
  # debian a2ensite
  define ensite() {
    file { "/etc/apache2/sites-enabled/$name":
      ensure => "../sites-available/$name",
      notify => Service[$httpd_service];
    }
  }
  # debian dissite
  define dissite() {
    file { "/etc/apache2/sites-enabled/$name":
      ensure => absent,
      notify => Service[$httpd_service];
    }
  }

}


class apache::ssl inherits apache {

  if $ssl_module != "" {
    package { $ssl_module:
      ensure => installed,
    }
  }

  # generates self-signed certs
  if $operatingsystem == "Debian" {
    package { "ssl-cert":
      ensure => installed,
    }
  }

}

class apache::nagios {

  # workaround fins que tinguem fet aixo:
  # http://redmine.ingent.net/issues/769
  case $fqdn {
    "sw01.unespai.com": {}
    "orinador.escala.local": {}
    "servidor1.cecot.es": {}
    default: {
      nagios::nsca_node::wrapper_check { "apache":
        command => "/usr/local/nagios/libexec/check_procs -C $httpd_service -w 1:50 -c 1:100",
      }
    }
  }
}
