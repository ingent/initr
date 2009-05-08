require 'puppet/util/rails/collection_merger'
require 'puppet/rails/param_value'

class Puppet::Rails::ParamName < ActiveRecord::Base

  establish_connection "puppet_#{RAILS_ENV}"

  include Puppet::Util::CollectionMerger
    has_many :param_values, :dependent => :destroy 

    def to_resourceparam(resource, source)
        hash = {}
        hash[:name] = self.name.to_sym
        hash[:source] = source
        hash[:value] = resource.param_values.find(:all, :conditions => [ "param_name_id = ?", self.id]).collect { |v| v.value }
        if hash[:value].length == 1
            hash[:value] = hash[:value].shift
        elsif hash[:value].empty?
            hash[:value] = nil
        end
        Puppet::Parser::Resource::Param.new hash
    end
end

# $Id$
