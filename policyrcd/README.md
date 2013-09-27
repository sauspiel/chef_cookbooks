Description
===========
Installs a simple bash script to manage policy-rc.d and remove 
deamons from management.

Requirements
============
None


Attributes
==========
node["policy-rc.d"]["status"]

Usage
=====
Disable apt from starting any daemons after install:

    policyrcd_policy "default-policy" do
      action :create
      default-policy true
      status "101"
    end

Disable apt from taking any actions with apache2

    policyrcd_policy "apache2" do
      action :create
      default-policy true
      status "101"
    end
    
Allow apt from taking any actions with apache2

    policyrcd_policy "apache2" do
      action :create
      default-policy true
      status "0"
    end
