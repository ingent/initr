# From http://www.mozillamessaging.com/en-US/thunderbird/all.html

# Class name must match a package id in an XML in files/packages

class wpkg::thunderbird {

  file {
    "$wpkg_base/software/thunderbird":
      ensure => directory;
  }

  wpkg::download {
    "thunderbird":
      to => "thunderbird",
      url => "http://download.mozilla.org/?product=thunderbird-9.0.1&os=win&lang=ca",
      creates => "Thunderbird Setup 9.0.1.exe";
  }

}
