def smartmontools_megaraid_devices
  # ohai plugin for megaraid is required!
  # => https://github.com/gpapilion/raid_controllers_ohai
  devices = Array.new
  ctrl = node[:raid_controllers].values.select { |ctrl| ctrl['type'] =~ /MegaRAID/ }.first
  ctrl['physical_disks'].values[0].each do |k,device|
    devices << "sda -d megaraid,#{device['Device Id']}"
  end
  return devices
end
