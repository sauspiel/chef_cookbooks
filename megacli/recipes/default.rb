package "libsysfs2" do
  action :upgrade
end


# Workaround for MegaCli64 error:

#The dependent library libsysfs.so.2.0.1 not available. Please contact LSI
#for distribution of the package
#OSSpecificInitialize: Failed to load libsysfs.so.2.0.2 Please ensure that
#libsfs is present in the system.
link "/lib/libsysfs.so.2.0.2" do
  to "/lib/libsysfs.so.2"
end

cookbook_file "MegaCli64" do
  path "/usr/bin/MegaCli64"
  owner "root"
  group "root"
  mode "0700"
  action :create
end

file "/usr/bin/megacli" do
  action :delete
  not_if { Pathname.new('/usr/bin/megacli').symlink? }
end

link "/usr/bin/megacli" do
  to "/usr/bin/MegaCli64"
end


