#!/usr/bin/env rspec

require 'spec_helper'

describe 'hp_mcp::hphealth', :type => 'class' do

  context 'on a non-supported operatingsystem' do
    let :facts do {
      :osfamily        => 'foo',
      :operatingsystem => 'foo'
    }
    end
    it 'should fail' do
      expect {
        should raise_error(Puppet::Error, /Unsupported osfamily: foo operatingsystem: foo, module hp_mcp only support operatingsystem/)
      }
    end
  end

  redhatish = ['CentOS', 'OracleLinux', 'OEL']

  context 'on a supported operatingsystem, non-HP platform' do
    (['CentOS']).each do |os|
      context "for operatingsystem #{os}" do
        let(:params) {{}}
        let :facts do {
          :operatingsystem => os,
          :manufacturer    => 'foo'
        }
        end
        it { should_not contain_package('hp-OpenIPMI') }
        it { should_not contain_package('hponcfg') }
        it { should_not contain_package('hp-health') }
        it { should_not contain_package('hpacucli') }
        it { should_not contain_package('hp-ilo') }
        it { should_not contain_service('hp-ilo') }
        it { should_not contain_service('hp-health') }
      end
    end
  end

  context 'on a supported operatingsystem, HP platform, default parameters' do
    (['CentOS']).each do |os|
      context "for operatingsystem #{os}" do
        let :facts do {
          :operatingsystem => os,
          :manufacturer    => 'HP'
        }
        end
        it { should contain_package('hponcfg').with_ensure('present') }
        it { should contain_package('libxslt').with_ensure('present') }
        it { should contain_package('hp-health').with_ensure('present') }
        it { should contain_package('hpacucli').with_ensure('present') }
        it { should contain_service('hp-health').with_ensure('running') }

        context "for operatingsystemrelease 5.0" do
          let :facts do {
            :operatingsystem        => os,
            :operatingsystemrelease => '5.0',
            :manufacturer           => 'HP'
          }
          end
          it { should contain_package('hp-OpenIPMI').with(
            :ensure => 'present',
            :name   => 'hp-OpenIPMI'
          )}
          it { should contain_package('hp-ilo').with_ensure('present') }
          it { should contain_service('hp-ilo').with_ensure('running') }
        end

        context "for operatingsystemrelease 5.3" do
          let :facts do {
            :operatingsystem        => os,
            :operatingsystemrelease => '5.3',
            :manufacturer           => 'HP'
          }
          end
          it { should contain_package('hp-OpenIPMI').with(
            :ensure => 'present',
            :name   => 'hp-OpenIPMI'
          )}
          it { should contain_package('hp-ilo').with_ensure('absent') }
          it { should contain_service('hp-ilo').with_ensure('') }
        end

        context "for operatingsystemrelease 6.0" do
          let :facts do { 
            :operatingsystem        => os,
            :operatingsystemrelease => '6.0',
            :manufacturer           => 'HP'
          } 
          end
          it { should contain_package('hp-OpenIPMI').with(
            :ensure => 'present',
            :name   => 'OpenIPMI'
          )}
          it { should contain_package('hp-ilo').with_ensure('absent') } 
          it { should contain_service('hp-ilo').with_ensure('') } 
        end
      end
    end
  end

  context 'on a supported operatingsystem, HP platform, custom parameters' do
    (['CentOS']).each do |os|
      context "for operatingsystem #{os} operatingsystemrelease 6.0" do
        let :params do {
          :autoupgrade    => true,
          :service_ensure => 'stopped'
        }
        end
        let :facts do {
          :operatingsystem        => os,
          :operatingsystemrelease => '6.0',
          :manufacturer           => 'HP'
        }
        end
        it { should contain_package('hp-OpenIPMI').with(
          :ensure => 'latest',
          :name   => 'OpenIPMI'
        )}
        it { should contain_package('hponcfg').with_ensure('latest') }
        it { should contain_package('libxslt').with_ensure('present') }
        it { should contain_package('hp-health').with_ensure('latest') }
        it { should contain_package('hpacucli').with_ensure('latest') }
        it { should contain_package('hp-ilo').with_ensure('absent') }
        it { should contain_service('hp-ilo').with_ensure('') }
        it { should contain_service('hp-health').with_ensure('stopped') }
      end
    end
  end

end
