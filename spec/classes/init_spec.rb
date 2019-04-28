require 'spec_helper'
describe 'debianupgrade' do
  context 'with default values for all parameters' do
    it { should contain_class('debianupgrade') }
  end
end
