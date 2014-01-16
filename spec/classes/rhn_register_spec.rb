require 'spec_helper'

describe 'rhn_register', :type => 'class' do
  context "On a RedHat system" do
    let :facts do {
      :osfamily => 'RedHat',
      :operatingsystem => 'RedHat'
    } end

    context "with a username and password supplied" do
      let :params do {
        :username => 'test',
        :password => 'test',
      } end

      it { should contain_exec('register_with_rhn').with(
        :command => '/usr/sbin/rhnreg_ks --username test --password test'
      ) }

      context "with a server url defined" do
        let :params do {
          :username => 'test',
          :password => 'test',
          :serverurl => 'http://example.com/XMLRPC',
        } end

        it { should contain_exec('register_with_rhn').with(
          :command => '/usr/sbin/rhnreg_ks --username test --password test --serverUrl http://example.com/XMLRPC'
        ) }
      end
    end

    context "without a username/password or activation key supplied" do
      it { expect { should raise_error(Puppet::Error, /Either an activation key or username\/password is required to register/) }}
    end
  end

  context "On an Ubuntu system" do

    let :facts do {
      :osfamily        => 'Debian',
      :operatingsystem => 'Ubuntu'
    } end

    let :params do {
      :username => 'test',
      :password => 'test',
    } end
    
    it { expect { should raise_error(Puppet::Error, /You can't register Ubuntu with RHN or Satellite using this puppet moudle/) }}

  end
end
