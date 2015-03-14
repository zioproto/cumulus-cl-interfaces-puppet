require 'spec_helper'
require 'pry-debugger'
cl_iface = Puppet::Type.type(:cumulus_bond)

describe cl_iface do
  let :params do
    [
      :name,
      :ipv4,
      :ipv6,
      :alias_name,
      :addr_method,
      :mtu,
      :virtual_ip,
      :virtual_mac,
      :vids,
      :pvid,
      :location,
      :mstpctl_portnetwork,
      :mstpctl_bpduguard,
      :clagd_enable,
      :clagd_priority,
      :clagd_peer_ip,
      :clagd_sys_mac,
      :clagd_args,
      :mode, :miimon, :min_links, :lacp_rate,
      :xmit_hash_policy
    ]
  end

  let :properties do
    [:ensure]
  end

  it 'should have expected properties' do
    properties.each do |property|
      expect(cl_iface.properties.map(&:name)).to be_include(property)
    end
  end

  it 'should have expected parameters' do
    params.each do |param|
      expect(cl_iface.parameters).to be_include(param)
    end
  end

  context 'defaults for' do
    before do
      @bondtype = cl_iface.new(:name => 'bond0',
                               :slaves => ['bond0-2'])
    end
    context 'lacp_rate' do
      it { expect(@bondtype.value(:lacp_rate)).to eq 1 }
    end
  end
  context 'validation' do
    context 'vrr parameters' do
      context 'if not all vrr parameters are set' do
        it do
          expect { cl_iface.new(:name => 'bond0',
                                :slaves => 'swp1-2',
                                'virtual_ip' => '10.1.1.1/24') }.to raise_error
        end
        context 'if all vrr parameters are set' do
          it do
            expect { cl_iface.new(:name => 'bond0',
                                  :slaves => 'swp1-2',
                                  :virtual_ip => '10.1.1.1/24',
                                  :virtual_mac => '00:00:5e:00:00:01') }.to_not raise_error
          end
        end

        context 'clag parameters' do
          context 'if not all clag parameters are set' do
            it { expect { cl_iface.new(:name => 'bond0',
                                       :slaves => 'swp1-2',
                                       :clagd_enable => 'yes') }.to raise_error }
          end
          context 'if not configured' do
            it { expect { cl_iface.new(:name => 'bond0') }.to_not raise_error }
          end
          context 'if all are configured' do
            it { expect { cl_iface.new(:name => 'bond0',
                                       :slaves => 'swp1-2',
                                       :clagd_enable => true,
                                       :clagd_priority => 2000,
                                       :clagd_sys_mac => '44:38:38:ff:00:11',
                                       :clagd_peer_ip => '10.1.1.1/24') }.to_not raise_error }
          end
          context 'if clagd_args is specified' do
            context 'and clagd_enable' do
              context ' is not set' do
                it { expect { cl_iface.new(:name => 'bond0',
                                           :clagd_args => '--vm') }.to raise_error }
              end
              context 'is set' do
                it { expect {
                  cl_iface.new(:name => 'bond0',
                               :slaves => 'swp1-2',
                               :clagd_enable => true,
                               :clagd_priority => 2000,
                               :clagd_sys_mac => '44:38:38:ff:00:11',
                               :clagd_peer_ip => '10.1.1.1/24',
                               :clagd_args => '--vm') }.to_not raise_error }
              end
            end
          end
        end
      end
    end
  end
end