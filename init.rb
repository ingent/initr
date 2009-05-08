# Redmine initr plugin
begin
  require 'redmine'
  
  RAILS_DEFAULT_LOGGER.info 'Starting initr plugin for Redmine'

  # Initr requires DelayedJob plugin
  unless defined?(Delayed::Job)
    raise Exception.new("ERROR: DelayedJob plugin is not installed. Please install it from http://github.com/tobi/delayed_job")
  end

  # Patches to the Redmine core.
  require 'dispatcher'
  require 'project_patch'
  Dispatcher.to_prepare do
    Project.send(:include, ProjectPatch)
  end 

  Redmine::Plugin.register :initr_plugin do
    name 'initr'
    author 'Ingent'
    description 'Node management with redmine and puppet'
    version '0.0.1'
    settings :default => {
      'puppetmaster_ip' => '127.0.0.1',
      'autosign' => '/etc/puppet/autosign.conf',
      'puppetca' => '/usr/bin/puppetca',
      'slicehost_api_password' => '0'
    },
    :partial => 'initradmin/settings'

    # This plugin adds a project module
    # It can be enabled/disabled at project level (Project settings -> Modules)
    project_module :initr do
      permission :view_nodes,
      :node    => [:list, :view, :facts],
      :require => :member
      permission :manage_nodes,
      { :node  => [:new, :destroy],
        :base    => [:configure] },
      :require => :member
      permission :use_classes,
      :klass   => [:list, :create, :configure, :destroy],
      :require => :member
      # public:
      #  * node/get_host_definition
      # admin only:
      #  * conf_names
      #  * initr_admin
      #  * klass_names
      #  * node/list when no project selected (all).
    end

    # A new item is added to the project menu
    menu :project_menu, :initr, { :controller => 'node', :action => 'list' }, :caption => 'Initr'
    menu :top_menu, :initr, { :controller => 'initradmin' }, :caption =>
      'Admin-Initr'
  end
  
  # dump to a file some server info need by scripts (delayed_jobs_worker, initr_login...)
  open("#{RAILS_ROOT}/vendor/plugins/initr/server_info.yml",'w') do |f|
    f.puts "# Autogenerated from initr/init.rb"
    f.puts "# Changes will be lost"
    f.puts "RAILS_ROOT: #{RAILS_ROOT}"
    f.puts "RAILS_ENV: #{RAILS_ENV}"
    f.puts "DOMAIN: localhost:8000" #TODO: can we set this automatically?
  end
  
rescue MissingSourceFile
  RAILS_DEFAULT_LOGGER.info 'Warning: not running inside Redmine'
end


# load initr_plugins
#paths = []
#base=File.dirname(__FILE__)+"/plugins/"
#(Dir.entries(File.dirname(__FILE__)+"/plugins") - [".",".."]).each do |plugin|
#  paths << base+plugin+"/app/controllers"
#  paths << base+plugin+"/app/models"
#  paths << base+plugin+"/app/views"
#end
#config.load_paths += paths

#puts "\n\n\n\n\n----------#{File.dirname(__FILE__)}\n#{config.load_paths.join("\n")}\n----------\n\n\n\n\n"
