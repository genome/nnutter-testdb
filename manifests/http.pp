# testdb::http

class testdb::http(
  $fq_hostname,
  $redirect = 'true',
) {
  include testdb::params
  include apache
  #include wildcard_gsc_wustl_edu

  $docroot = '/var/www'

  file { $docroot :
    ensure => directory,
  }

  if str2bool($redirect) {
    apache::vhost { $fq_hostname :
      servername   => $fq_hostname,
      port         => '80',
      docroot      => $docroot,
      rewrite_cond => '%{HTTPS} off',
      rewrite_rule => "(.*) https://${fq_hostname}%{REQUEST_URI}",
    }
  }
  else {
    apache::vhost { $fq_hostname :
      servername => $fq_hostname,
      port       => '80',
      docroot    => $docroot,
      proxy_dest => 'http://localhost:3000',
    }
  }

  #apache::vhost { "${fq_hostname}-ssl":
  #  servername => $fq_hostname,
  #  port       => '443',
  #  ssl        => true,
  #  docroot    => $docroot,
  #  proxy_dest => 'http://localhost:3000',
  #  ssl_key    => $wildcard_gsc_wustl_edu::key_path,
  #  ssl_cert   => $wildcard_gsc_wustl_edu::cert_path,
  #  require    => Class['wildcard_gsc_wustl_edu'],
  #}
}
