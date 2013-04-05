include Chef::Mixin::LanguageIncludeRecipe

action :before_compile do

  if new_resource.bundler.nil?
    new_resource.bundler rails_resource && rails_resource.bundler
  end

  unless new_resource.bundler
    include_recipe "unicorn"
  end

  new_resource.bundle_command rails_resource && rails_resource.bundle_command

  unless new_resource.restart_command
    new_resource.restart_command do
      execute "/etc/init.d/#{new_resource.name} restart" do
        user "root"
      end
    end
  end

end

action :before_deploy do
end

action :before_migrate do
end

action :before_symlink do
end

action :before_restart do

  new_resource = @new_resource

  new_resource.environment_vars['RAILS_ENV'] = new_resource.environment_name
  new_resource.environment_vars['RACK_ENV'] = new_resource.environment_name

  command = new_resource.command
  config_path = "#{node[:unicorn][:config_path]}/#{new_resource.name}.conf.rb"
  if command.nil?
    command = new_resource.bundler ? "#{new_resource.bundle_command} exec unicorn" : "unicorn"
    command += " -Dc #{config_path}"
  end

  unicorn_app new_resource.name do
    app_root "#{new_resource.path}/current"
    worker_count new_resource.worker_processes
    preload new_resource.preload_app
    worker_timeout new_resource.worker_timeout
    environment_vars new_resource.environment_vars
    memory_limit new_resource.memory_limit
    cpu_limit new_resource.cpu_limit
    user new_resource.user
    group new_resource.group
    command command
    config_path config_path
    cookbook new_resource.cookbook 
    template new_resource.template
  end

  logrotate new_resource.name do
    files ["#{new_resource.path}/current/log/*.log"]
    frequency "daily"
    rotate_count 10
    compress true
    user new_resource.user
    group new_resource.group
    restart_command "/bin/kill -USR1 `cat #{new_resource.path}/current/tmp/unicorn/unicorn.pid` > /dev/null"
  end
end

action :after_restart do
end

protected

def rails_resource
  new_resource.application.sub_resources.select{|res| res.type == :rails}.first
end
