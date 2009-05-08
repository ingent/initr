class Puppet::Rails::FactValue < ActiveRecord::Base
  establish_connection "puppet_#{RAILS_ENV}"
  belongs_to :fact_name
  belongs_to :host
end

# $Id: fact_value.rb 1952 2006-12-19 05:47:57Z luke $
