require 'spec_helper_acceptance'

describe 'testdb class' do
  context 'default parameters' do
    ssl_cert = '/etc/ssl/certs/ssl-cert-snakeoil.pem'
    ssl_key = '/etc/ssl/private/ssl-cert-snakeoil.key'
    manifest = <<-EOS
      class { 'testdb':
        redirect => 'true',
        ssl      => 'true',
        ssl_key  => '#{ssl_key}',
        ssl_cert => '#{ssl_cert}',
      }
    EOS

    it 'should apply without failure' do
      apply_manifest_on hosts, manifest, :catch_failures => true
    end

    it 'should re-apply without changes' do
      apply_manifest_on hosts, manifest, :catch_changes => true
    end

    it 'default host should respond' do
        shell("curl --head 'http://localhost'") do |result|
            expect(result.stdout).to match(/302 Found/)
            expect(result.stdout).to match(/https:\/\/localhost/)
        end

        shell("curl --insecure 'https://localhost'") do |result|
            expect(result.stdout).to match(/database_count/)
            expect(result.stdout).to match(/template_count/)
        end
    end
  end
end


