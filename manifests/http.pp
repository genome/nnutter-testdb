# testdb::http

class testdb::http(
  $fq_hostname,
  $redirect,
  $ssl,
  $ssl_key,
  $ssl_cert,
) {
  include apache

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

  if str2bool($ssl) {
    apache::vhost { "${fq_hostname}-ssl":
      servername => $fq_hostname,
      port       => '443',
      ssl        => true,
      docroot    => $docroot,
      proxy_dest => 'http://localhost:3000',
      ssl_key    => $ssl_key,
      ssl_cert   => $ssl_cert,
    }
  }
}
