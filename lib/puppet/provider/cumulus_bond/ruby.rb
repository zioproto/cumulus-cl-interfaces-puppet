require 'cumulus/ifupdown2'
Puppet::Type.type(:cumulus_bond).provide :ruby do
  confine operatingsystem: [:cumulus_linux]
  include Cumulus::Ifupdown2
end