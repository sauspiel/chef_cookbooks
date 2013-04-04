define :unicorn_app do
  include_recipe "unicorn"
  include_recipe "bluepill"

  %w(cache pids unicorn).each do |dir|
    directory "#{params[:app_root]}/tmp/#{dir}" do
      owner params[:user]
      group params[:user]
      mode 0755
      recursive true
    end
  end

  directory "#{params[:app_root]}/log" do
    owner params[:user]
    group params[:user]
    mode 0755
    recursive true
  end

  config_path = params[:config_path] || "#{node[:unicorn][:config_path]}/#{params[:name]}.conf.rb"

  template config_path do
    cookbook params[:cookbook] || 'unicorn'
    source params[:template] || "unicorn.conf.erb"
    owner params[:user]
    group params[:group]
    mode 0644
    variables :app_name => params[:name], :app_root => params[:app_root], :worker_count => params[:worker_count], :preload => params[:preload]
  end

  template "#{node[:bluepill][:conf_dir]}/#{params[:name]}.pill" do
    cookbook 'unicorn'
    source "bluepill.conf.erb"
    variables :app_name => params[:name], 
      :app_root => params[:app_root], 
      :environment_vars => params[:environment_vars] || Hash.new,
      :memory_limit => params[:memory_limit] || 100, 
      :user => params[:user] || "deploy", 
      :group => params[:group] || "deploy", 
      :cpu_limit => params[:cpu_limit] ||50,
      :command => params[:command], 
      :preload => params[:preload]
  end

  bluepill_service params[:name] do
    cookbook 'unicorn'
    template 'bluepill.conf.erb'
    action [:enable, :load, :start]
  end
end
