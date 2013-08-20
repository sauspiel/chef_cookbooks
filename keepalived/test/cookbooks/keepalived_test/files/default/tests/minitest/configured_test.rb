#
# Cookbook Name:: keepalived_test
# Recipe:: configured
#

require_relative "./support/helpers"

describe_recipe "keepalived_test::configured" do
  include KeepalivedTestHelpers

  describe "configured keepalived" do
    it "should create a keepalived configuration file" do
      file("/etc/keepalived/keepalived.conf").must_exist
    end

    it "should enable and start the daemon" do
      service("keepalived").must_be_running
      service("keepalived").must_be_enabled
    end

    it "should have virtual address bound" do
      sleep(5) # give keepalived some time to get setup
      refute_nil(
        `ip addr sh eth0`.split("\n").detect { |l| l.include?("10.0.2.254") },
        "Expected bound virtual IP address not found"
      )
    end

  end
end
