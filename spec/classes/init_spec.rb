require 'spec_helper'
describe 'testdb' do

  context 'with defaults for all parameters' do
    it { should contain_class('testdb') }
  end
end
