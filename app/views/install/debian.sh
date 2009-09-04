echo "Setting up initr node `hostname`..."
cat << FI > /etc/apt/sources.list
##################
# Puppet Managed #
##################
#
# debian stable
deb http://ftp.fr.debian.org/debian lenny main contrib non-free
deb http://security.debian.org lenny/updates main contrib non-free

# debian testing
deb http://ftp.fr.debian.org/debian squeeze main contrib non-free
deb http://security.debian.org squeeze/updates main contrib non-free
FI
cat << FI > /etc/apt/preferences
##################
# Puppet Managed #
##################
#
# Highest priority to stable
Package: *
Pin: release a=stable
Pin-Priority: 700

Package: *
Pin: release a=testing
Pin-Priority: 600

# we want puppet from testing
Package: puppet
Pin: release a=testing
Pin-Priority: 700

# we want rubygems from testing
Package: rubygems
Pin: release a=testing
Pin-Priority: 700

Package: rubygems1.8
Pin: release a=testing
Pin-Priority: 700
FI
mkdir -p /etc/puppet
cat << FI > /etc/puppet/puppet.conf
[main]
    vardir = /var/lib/puppet
    logdir = /var/log/puppet
    rundir = /var/run/puppet
    ssldir = /var/lib/puppet/ssl
[puppetd]
    server = one.ingent.net
    classfile = /var/lib/puppet/state/classes.txt
    localconfig = /var/lib/puppet/localconfig
    factsync = true
    report = true
FI
apt-get update -qq; apt-get install -qq -o DPkg::Options::=--force-confold puppet lsb-release && echo "OK! Look for puppetd logs in syslog (tail -f /var/log/syslog)."