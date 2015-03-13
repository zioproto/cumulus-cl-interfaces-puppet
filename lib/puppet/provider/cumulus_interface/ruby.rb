require 'cumulus/ifupdown2'
Puppet::Type.type(:cumulus_interface).provide :ruby do
  #confine operatingsystem: [:cumulus_linux]

  def build_desired_config
    config = Ifupdown2Config.new(resource)
    config.update_addr_method
    config.update_address
    %w(vids pvid).each do |attr|
      config.update_attr(attr, 'bridge')
    end
    config.update_alias_name
    config.update_vrr
    # attributes with no suffix like bond-, or bridge-
    %w(mstpctl-portnetwork mstpctl-bpduguard clagd_enable clagd_priority
    clagd_args clagd_peer_ip).each do |attr|
      config.update_attr(attr)
    end
    # copy to instance variable
    @config = config
  end

  def config_changed?
    build_desired_config
    Puppet.debug "desired config #{@config.confighash}"
    Puppet.debug "current config #{@config.currenthash}"
    Puppet.debug "config changed #{@config.compare_with_current}"
    ! @config.compare_with_current
  end

  def update_config
    @config.write_config
  end
end