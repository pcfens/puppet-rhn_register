require 'spec_helper'

describe 'rhn_register' do
  context 'On a RedHat system' do
    let :facts do
      {
        os: {family: 'RedHat', name: 'RedHat'},
      }
    end

    describe 'using classic registration' do
      context 'with a username and password supplied' do
        let :params do
          {
            username: 'test',
            password: 'test',
          }
        end

        it {
          is_expected.to contain_exec('register_with_rhn').with(
            command: '/usr/sbin/rhnreg_ks --username=test --password=test',
          )
        }
      end

      context 'with a server url defined' do
        let :params do
          {
            username: 'test',
            password: 'test',
            serverurl: 'http://example.com/XMLRPC',
          }
        end

        it {
          is_expected.to contain_exec('register_with_rhn').with(
            command: '/usr/sbin/rhnreg_ks --username=test --password=test --serverUrl=http://example.com/XMLRPC',
          )
        }
      end

      context 'with some additional bool options set' do
        let :params do
          {
            username: 'test',
            password: 'test',
            rhnsd: false,
            virtinfo: false,
          }
        end

        it {
          is_expected.to contain_exec('register_with_rhn').with(
            command: '/usr/sbin/rhnreg_ks --username=test --password=test --novirtinfo --norhnsd',
          )
        }
      end

      context 'without a username/password or activation key supplied' do
        it { is_expected.to raise_error(Puppet::Error, %r{Either an activation key or username\/password is required to register}) }
      end
    end

    describe 'using subscription-manager' do
      context 'with a username and password supplied' do
        let :params do
          {
            use_classic: false,
            username: 'test',
            password: 'test',
          }
        end

        it {
          is_expected.to contain_exec('register_with_rhn').with(
            command: '/usr/bin/subscription-manager register --username=test --password=test --auto-attach',
          )
        }
      end

      context 'with a server url defined' do
        let :params do
          {
            use_classic: false,
            username: 'test',
            password: 'test',
            serverurl: 'http://example.com/XMLRPC',
          }
        end

        it {
          is_expected.to contain_exec('register_with_rhn').with(
            command: '/usr/bin/subscription-manager register --username=test --password=test --serverurl=http://example.com/XMLRPC --auto-attach',
          )
        }
      end

      context 'without a username/password or activation key supplied' do
        it { is_expected.to raise_error(Puppet::Error, %r{Either an activation key or username\/password is required to register}) }
      end
    end
  end

  context 'On an Ubuntu system' do
    let :facts do
      {
        os: {family: 'Debian', name: 'Ubuntu'},
      }
    end

    let :params do
      {
        username: 'test',
        password: 'test',
      }
    end

    it { is_expected.to raise_error(Puppet::Error, %r{You can't register Ubuntu with RHN or Satellite using this puppet module}) }
  end
end
