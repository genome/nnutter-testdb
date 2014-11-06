# == Class: testdb
#
# Full description of class testdb here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { testdb:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2014 Your name here, unless otherwise noted.
#
class testdb (
  $perl_version      = '5.20.1',
  $service_user      = undef,
  $deploy_dir        = undef,
  $revision          = $testdb::params::revision,
  $db_admin_password = $testdb::params::db_admin_password,
  $fq_hostname       = $testdb::params::fq_hostname,
  $redirect          = $testdb::params::redirect,
  $source            = $testdb::params::source,
  $ssl               = $testdb::params::ssl,
  $ssl_key           = 'none',
  $ssl_cert          = 'none',
) inherits testdb::params {
  include perlbrew

  anchor { 'testdb::begin':
    before => Class['testdb::app', 'testdb::http'],
  }

  if $service_user {
    $user = $service_user
  }
  else {
    $user = 'test_db'
    $home = "/home/${user}"
    $dir = "${home}/TestDbServer"
    user { $user :
      ensure     => present,
      shell      => '/bin/bash',
      home       => $home,
      managehome => true,
      before     => Class['testdb::app'],
    }
  }

  class { 'testdb::app':
    perl_version      => $perl_version,
    dir               => $dir,
    user              => $user,
    revision          => $revision,
    db_admin_password => $db_admin_password,
    source            => $source,
  }

  class { 'testdb::http':
    fq_hostname => $fq_hostname,
    redirect    => $redirect,
    ssl         => $ssl,
    ssl_key     => $ssl_key,
    ssl_cert    => $ssl_cert,
  }

  anchor { 'testdb::end':
    require => Class['testdb::app', 'testdb::http'],
  }
}
