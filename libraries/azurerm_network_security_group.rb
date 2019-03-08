# frozen_string_literal: true

require 'azurerm_resource'

class AzurermNetworkSecurityGroup < AzurermPluralResource
  name 'azurerm_network_security_group'
  desc 'Verifies settings for Network Security Groups'
  example <<-EXAMPLE
    azurerm_network_security_groups(resource_group: 'example') do
      it{ should exist }
    end
  EXAMPLE

  def initialize(resource_group: nil, name: nil)
    resp = management.network_security_group(resource_group, name)
    return if has_error?(resp)

    @table = resp
  end
  
  attr_reader :table

  filter = FilterTable.create
  filter.register_custom_matcher(:exists?) { |x| !x.entries.empty? }
  filter.register_column(:names,                       field: :name)
        .register_column(:description,                field: :description)
        .register_column(:protocol,                   field: :protocol)
        .register_column(:sourcePortRange,            field: :sourcePortRange)
        .register_column(:destinationPortRange,       field: :destinationPortRange)
        .register_column(:sourceAddressPrefix,        field: :sourceAddressPrefix)
        .register_column(:destinationAddressPrefix,   field: :destinationAddressPrefix)
        .register_column(:access,                     field: :access)
        .register_column(:priority,                   field: :priority)
        .register_column(:direction,                  field: :direction)
        .register_column(:sourcePortRanges,           field: :sourcePortRanges)
        .register_column(:destinationPortRanges,      field: :destinationPortRanges)
        .register_column(:sourceAddressPrefixes,      field: :sourceAddressPrefixes)
        .register_column(:destinationAddressPrefixes, field: :destinationAddressPrefixes)
  filter.install_filter_methods_on_resource(self, :security_rule_details)

  include Azure::Deprecations::StringsInWhereClause

  def security_rule_details
    @table['properties']['securityRules'].each_with_index do |rule|
      parse_security_rules(rule)
    end
  end

  def parse_security_rules(security_rule)
    
    rule = { 
      name: security_rule['name'],
      description: security_rule['properties']['description'],
      protocol: security_rule['properties']['protocol'],
      sourcePortRange: security_rule['properties']['sourcePortRange'],
      destinationPortRange: security_rule['properties']['destinationPortRange'],
      sourceAddressPrefix: security_rule['properties']['sourceAddressPrefix'],
      destinationAddressPrefix: security_rule['properties']['destinationAddressPrefix'],
      access: security_rule['properties']['access'],
      priority: security_rule['properties']['priority'],
      direction: security_rule['properties']['direction'],
      sourcePortRanges: security_rule['properties']['sourcePortRanges'],
      destinationPortRanges: security_rule['properties']['destinationPortRanges'],
      sourceAddressPrefixes: security_rule['properties']['sourceAddressPrefixes'],
      destinationAddressPrefixes: security_rule['properties']['destinationAddressPrefixes'],
    }
    puts rule.inspect
    rule
  end


  def to_s
    'Network Security Group'
  end
end
