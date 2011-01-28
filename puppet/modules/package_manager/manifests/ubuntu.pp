class package_manager::ubuntu {

  case $lsbdistcodename {
#    "lenny":   { include package_manager::debian::lenny   } # stable
#    "squeeze": { include package_manager::debian::squeeze } # testing
    default: {}
  }
  exec {
    "apt-get update":
      refreshonly => true;
  }
  file {
    "/etc/apt/preferences":
      # TODO
      notify => Exec["apt-get update"];
    "/etc/apt/sources.list":
      content => template("package_manager/sources.list.erb"),
      notify => Exec["apt-get update"];
    "/etc/apt/sources.list.d/security.sources.list":
      content => template("package_manager/security.sources.list.erb"),
      notify => Exec["apt-get update"];
  }

}
