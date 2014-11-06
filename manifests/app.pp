class testdb::app(
  $perl_version,
  $dir,
  $user,
  $revision,
  $db_admin_password,
  $source,
) {
  anchor { 'testdb::app::begin':
    before => Class['postgresql::server', 'postgresql::lib::devel'],
  }

  package { 'git':
    ensure => present,
  }

  vcsrepo { $dir :
    ensure   => present,
    provider => git,
    source   => $source,
    revision => $revision,
    require  => Package['git'],
  }

  file { "${dir}/log":
    ensure  => directory,
    owner   => $user,
    require => Vcsrepo[$dir],
  }

  perlbrew::perl::ssl { $perl_version :
    version => $perl_version,
  }

  perlbrew::carton { 'TestDbServer':
    perl_version => $perl_version,
    carton_dir   => $dir,
    subscribe    => Vcsrepo[$dir],
  }

  class { 'postgresql::globals':
    encoding            => 'UTF8',
    locale              => 'en_US.utf8',
    version             => '9.2',
    manage_package_repo => true,
  }

  class { 'postgresql::server':
    listen_addresses => '*',
    require          => Class['postgresql::globals'],
  }
  include 'postgresql::server'

  class { 'postgresql::lib::devel':
    package_name => 'postgresql-server-dev-9.2',
    require      => Class['postgresql::server'],
  }
  include 'postgresql::lib::devel'

  $db_name = 'test_db'
  $db_port = 5432
  $db_host = 'localhost'
  postgresql::server::role { $user :
    createdb      => true,
    createrole    => true,
    password_hash => postgresql_password($user, $db_admin_password),
  }

  postgresql::server::pg_hba_rule { "${user}-localhost" :
    type        => 'host',
    database    => 'all',
    user        => $user,
    address     => 'localhost',
    auth_method => 'trust',
    order       => '099',
  }

  postgresql::server::pg_hba_rule { "${user}-::1/128" :
    type        => 'host',
    database    => 'all',
    user        => $user,
    address     => '::1/128',
    auth_method => 'trust',
    order       => '099',
  }

  postgresql::server::db { $db_name :
    user     => $user,
    password => postgresql_password($user, $db_admin_password), # unused but required
    require  => Postgresql::Server::Role[$user],
  }

  file { "${dir}/test_db_server.production.conf":
    ensure  => present,
    content => template('testdb/test_db_server.production.conf.erb'),
    require => Vcsrepo[$dir],
  }

  perlbrew::cpan::module { 'App::Sqitch':
    perl_version => $perl_version,
  }

  package { 'libdbd-pg-perl':
    ensure  => present,
    require => Class['postgresql::server'],
  }

  file { "${dir}/sqitch/sqitch.conf":
    ensure  => present,
    content => template('testdb/sqitch.conf.erb'),
    require => Vcsrepo[$dir],
  }

  perlbrew::exec { 'sqitch-deploy':
    perl_version => $perl_version,
    cwd          => "${dir}/sqitch",
    command      => 'carton exec -- sqitch deploy',
    unless       => "carton exec -- sqitch status | /usr/bin/tail -n 1 | /bin/grep -q 'Nothing to deploy'",
    require      => [
      File["${dir}/sqitch/sqitch.conf"],
      Perlbrew::Carton['TestDbServer'],
      Perlbrew::Cpan::Module['App::Sqitch'],
      Package['libdbd-pg-perl'],
      Postgresql::Server::Db[$db_name],
    ],
  }

  file { '/etc/init/test-db.conf':
    ensure  => present,
    content => template('testdb/etc/init/test-db.conf.erb'),
  }

  service { 'test-db':
    ensure     => running,
    hasrestart => true,
    require    => [
      Perlbrew::Carton['TestDbServer'],
      Exec['sqitch-deploy'],
      Postgresql::Server::Db[$db_name],
    ],
    subscribe  => [
      Vcsrepo[$dir],
      Exec['sqitch-deploy'],
    ],
  }

  anchor { 'testdb::app::end':
    require => Class['postgresql::server', 'postgresql::lib::devel'],
  }
}
