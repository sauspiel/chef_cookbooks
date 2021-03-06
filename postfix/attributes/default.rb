#
# Author:: Joshua Timberman <joshua@opscode.com>
# Copyright:: Copyright (c) 2009, Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

default[:postfix][:mail_type]  = "client"
default[:postfix][:myhostname] = node[:fqdn]
default[:postfix][:mydomain]   = node[:domain]
default[:postfix][:myorigin]   = node[:fqdn]
default[:postfix][:relayhost]  = ""
default[:postfix][:mail_relay_networks] = "127.0.0.0/8"

default[:postfix][:smtpd_use_tls] = "no"

default[:postfix][:smtp_sasl_auth_enable] = "no"
default[:postfix][:smtp_sasl_password_maps]    = "hash:/etc/postfix/sasl_passwd"
default[:postfix][:smtp_sasl_security_options] = "noanonymous"
default[:postfix][:smtp_tls_cafile] = "/etc/postfix/cacert.pem"
default[:postfix][:smtp_use_tls]    = "yes"
default[:postfix][:smtp_sasl_user_name] = ""
default[:postfix][:smtp_sasl_passwd]    = ""
default[:postfix][:aliases] = {}
default[:postfix][:disabledsn] = false

default[:postfix][:sender_dependent_relayhost_maps] = "/etc/postfix/relayhost_map"
default[:postfix][:sender_dependent_relayhosts] = {}
default[:postfix][:inet_interfaces] = 'all'
default[:postfix][:inet_protocols] = "ipv4"
default[:postfix][:smtpd_upstream_proxy_protocol] = ''

default[:postfix][:virtual_alias_maps] = ''
