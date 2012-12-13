require 'chef/resource/package'
require 'chef/provider/package/apt'

### Example
#
#  apt_package_hold 'irssi' do
#   action [:install, :hold]
#  end
#
#  Installs irssi and sets it's dpkg state to \'hold\' to avoid manuall upgrades (by apt-get upgrade or apt-get dist-upgrade)
###

class Chef
  class Provider
    class Package
      class Apt
        class AptHold < Chef::Provider::Package::Apt

          def load_current_resource
            super
            @current_resource
          end

          def install_package(name, version)
            state_to_install(@new_resource.package_name)
            super
          end

          def upgrade_package(name, version)
            state_to_install(@new_resource.package_name)
            super
          end

          def action_hold
            state_to_hold(@new_resource.package_name)
          end

          def action_unhold
            state_to_install(@new_resource.package_name)
          end

          private

          def hold_action?
            return Array(@new_resource.action).include?(:hold)
          end

          def state_to_install(name)
            run_command_with_systems_locale(
              :command => "echo \"#{name} install\" | dpkg --set-selections"
            )
          end


          def state_to_hold(name)
            Chef::Log.info("#{name} will now be set on hold")
            run_command_with_systems_locale(
             :command => "echo \"#{name} hold\" | dpkg --set-selections"
            )
          end

        end
      end
    end
  end

  class Resource
    class AptPackageHold < Chef::Resource::Package::AptPackage
      
      def initialize(name, run_context=nil)
        super
        @action = :hold
        @resource_name = :apt_package_hold
        @provider = Chef::Provider::Package::Apt::AptHold
        @allowed_actions.push(:hold, :unhold)
      end
    end
  end
end


