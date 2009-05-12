
Initr plugin
============

Initr automates the lifecycle of computer systems.

From provision to operations, puts and keeps the nodes on track.

It uses `Puppet`_ as enabling technology.

Prerequisites
-------------

* Initr is a `Redmine`_ plugin, therefore you need a Redmine installation where install the plugin.

* You also will need a Puppetmaster configured with `storeconfigs`_.

* Configure in Redmine databases.yml puppetmaster database(s) for your environment(s) called ``puppet_#{RAILS_ENV}``

* You'll need to configure puppetmaster `external nodes`_ to call the script provided in bin/external_node.sh which gets node classes and parameters from an initr url.

Initr installation
------------------

1. Copy (or link) initr directory into Redmine vendor/plugins directory

2. Install `delayed_job`_ plugin into Redmine vendor/plugins directory

3. Migrate Redmine database for plugin with ``rake db:migrate:plugins``

4. Restart Redmine and check that it lists initr plugin on 'Admin -> Information' screen.

Initr daemon
------------

Initr uses delayed jobs to do some root tasks, you should start daemon provided in bin/delayed_jobs_daemon.rb.

Simply run:
::
 
 ruby bin/delayed_jobs_daemon.rb start

you can see daemon output at Redmine's ``tmp/pids/delayed_jobs_worker.rb.output``

Initr plugins installation
--------------------------

1. Copy or soft link each initr directory at puppet/modules/\*/ to Redmine vendor/plugins directory

   Another alternative is to add this line in environment.rb:
   ::
    
    config.plugin_paths += %W( #{RAILS_ROOT}/vendor/plugins/initr/puppet/modules )

2. Execute migrations with ``rake db:migrate:plugins``

3. Restart Redmine


Detailed plugin installation example
------------------------------------

Steps followed to install puppetmaster, redmine and initr on a CentOS 5.3 machine:
::
 
 # Install Puppetmaster and rubygems
 apt-get install puppetmaster rubygems
 # or
 yum install -y puppet-server rubygems
 
 # install mongrel and mongrel_cluster gems
 gem install mongrel mongrel_cluster --no-ri --no-rdoc
 
 # configure puppetmaster to use external nodes
 # with script /usr/local/sbin/puppet_external_nodes
 cat << EOF > /etc/puppet/puppet.conf
 [main]
     vardir         = /var/lib/puppet
     logdir         = /var/log/puppet
     rundir         = /var/run/puppet
     ssldir         = $vardir/ssl
     servertype     = mongrel
     external_nodes = /usr/local/sbin/puppet_external_nodes
 
 [puppetmasterd]
     # log files should always flush to disk
     autoflush     = true
     reports       = tagmail
     templatedir   = $vardir/templates
     modulepath    = $vardir/modules
     storeconfigs  = true
     dbadapter     = mysql
     dbmigrate     = false
     dbname        = initr
     dbuser        = initr
     dbpassword    = initr
     certname      = `hostname -f`
     node_terminus = exec
 EOF
 
 # create puppetmaster database
 mysqladmin create initr
 # add an user to access this database
 mysql -uroot -e "GRANT ALL PRIVILEGES ON initr.* TO initr@localhost IDENTIFIED BY 'initr';"
 
 # configure puppetmaster fileserver
 mkdir /var/lib/puppet/files
 cat << EOF > /etc/puppet/fileserver.conf
 [dist]
  path /var/lib/puppet/files
   allow *
 
 [facts]
  path /var/lib/puppet/facts
  allow *
 EOF
 
 
 # Install Redmine and required rails version
 cd /var/www
 svn co svn://rubyforge.org/var/svn/Redmine/trunk Redmine
 gem install -v=2.2.2 rails --no-ri --no-rdoc
 gem install mysql --no-ri --no-rdoc
 
 # edit config/environment.rb and add:
 # config.action_controller.session = { :session_key => "_myapp_session", :secret => "some secret phrase of at least 30 characters" }
 
 # set production environment
 export RAILS_ENV=production
 
 # configure and create Redmine databases
 cat << EOF > config/database.yml
 production:
   adapter: mysql
   database: redmine_trunk
   host: localhost
   username: root
   password:
 
 development:
   adapter: mysql
   database: redmine_development_trunk
   host: localhost
   username: root
   password:
 
 test:
   adapter: mysql
   database: redmine_test_trunk
   host: localhost
   username: root
   password:
 
 puppet_production:
   adapter: mysql
   database: initr
   host: localhost
   username: initr
   password: initr
 EOF
 
 rake db:create:all
 rake db:migrate
 
 # add an user for mongrel server
 adduser -r mongrel
 
 # user needs write access
 chown -R mongrel: /var/www/Redmine
 
 # configure mongrel cluster
 mongrel_rails cluster::configure -e production -p 8000 -N 1 -c /var/www/Redmine/ -a 127.0.0.1 --user mongrel --group mongrel
 mkdir /etc/mongrel_cluster
 ln -s /var/www/Redmine/config/mongrel_cluster.yml /etc/mongrel_cluster/Redmine
 
 # start Redmine
 mongrel_cluster_ctl start
 mongrel_rails cluster::restart -C /etc/mongrel_cluster/Redmine
 
 # Install Initr plugin
 cd vendor/plugins
 git clone git://github.com/descala/initr.git
 # initr needs delayed_job plugin
 git clone git://github.com/tobi/delayed_job.git
 # mongrel user needs write access on initr directory
 chown -R mongrel: initr
 # migrate plugin database
 cd ../../
 rake db:migrate:plugins
 chmod +x /var/www/Redmine/vendor/plugins/initr/bin/external_node.sh
 
 # Add user_observer and node_observer to Redmine config/environment.rb
 # at config.active_record.observers =
 
 mongrel_rails cluster::restart -C /etc/mongrel_cluster/Redmine
 
 # Initr adds some rights to Redmine, you will need to configure which roles are allowed to
 # use Initr, go to Administration, Roles, Permissions report section and look for Initr.
 # You'll need also to configure some variables for the plugin at Administration, Plugins:
 # Puppetmaster IP, Autosign file location, puppetca executable location and
 # Slicehost API Password (if you have it)


.. _storeconfigs: http://reductivelabs.com/trac/puppet/wiki/UsingStoredConfiguration
.. _external nodes: http://reductivelabs.com/trac/puppet/wiki/ExternalNodes
.. _delayed_job: http://github.com/tobi/delayed_job
.. _Redmine: http://www.redmine.org
.. _Puppet: http://puppet.reductivelabs.com