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
class testdb {
  include perlbrew
  include testdb::params

  $perl_version = '5.20.1'
  $user = 'test_db'
  $home = "/home/${user}"
  $dir = "${home}/TestDbServer"

  $revision          = $testdb::params::revision
  $db_admin_password = $testdb::params::db_admin_password
  $fq_hostname       = $testdb::params::fq_hostname
  $redirect          = $testdb::params::redirect

  user { $user :
    ensure     => present,
    shell      => '/bin/bash',
    home       => "/home/${user}",
    managehome => true,
  }

  class { 'testdb::app':
    perl_version      => $perl_version,
    dir               => $dir,
    user              => $user,
    revision          => $revision,
    db_admin_password => $db_admin_password,
    require           => User[$user],
  }

  class { 'testdb::http':
    fq_hostname => $fq_hostname,
    redirect    => $redirect,
  }

  anchor { 'testdb::end':
    require => Class['testdb::app', 'testdb::http'],
  }
}
