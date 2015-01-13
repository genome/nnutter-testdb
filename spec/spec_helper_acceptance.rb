require 'beaker-rspec'

hosts.each do |host|
  install_puppet({ :default_action => 'gem_install' })
  on host, "mkdir -p #{host['distmoduledir']}"
end

RSpec.configure do |c|
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  c.formatter = :documentation

  c.before :suite do
    hosts.each do |host|
      copy_module_to(host, :source => proj_root, :module_name => 'testdb')
      on host, puppet('module', 'install', 'puppetlabs-stdlib'),     { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'puppetlabs-apache'),     { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'puppetlabs-postgresql'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'puppetlabs-vcsrepo'),    { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'nnutter-perlbrew'),      { :acceptable_exit_codes => [0,1] }
    end
  end
end
