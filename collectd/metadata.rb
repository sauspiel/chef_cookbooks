name             "collectd"
maintainer       "Noan Kantrowitz"
maintainer_email "nkantrowitz@crypticstudios.com"
description      "Install and configure the collectd monitoring daemon and plugins"
license          "Apache 2.0"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "1.2.5"
supports         "debian"

depends "apt"
