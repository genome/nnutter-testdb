require 'spec_helper_acceptance'

describe 'testdb class' do
  context 'default parameters' do
    manifest = <<-EOS
      class { 'testdb': }
    EOS

    it 'should apply without failure' do
      apply_manifest_on hosts, manifest, :catch_failures => true
    end

    it 'should re-apply without changes' do
      apply_manifest_on hosts, manifest, :catch_changes => true
    end
  end
end
