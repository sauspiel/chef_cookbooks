name              "haproxy"
maintainer        "Joshua Sierles"
maintainer_email  "joshua@diluvia.net"
description       "Configures haproxy"
version           "1.1.0"

depends "apt"
depends "logrotate"
depends "rsyslog"
depends "eye"
depends 'runit'
depends "ssl_certificates", ">= 0.4.0"
