git node[:ohmyzsh][:shared_path] do
  repository "https://github.com/robbyrussell/oh-my-zsh.git"
  reference "master"
  action :checkout
  ignore_failure true
end

search( :users, "shell:*zsh" ).each do |u|

  theme = data_bag_item( "users", u["id"])["oh-my-zsh-theme"]

  template "#{u["home_dir"]}/.zshrc" do
    source "zshrc.erb"
    owner u[:id]
    group u[:groups].first
    variables( :theme => ( theme || node[:ohmyzsh][:theme] ), :shared => true, :source_dirs => node[:ohmyzsh][:source_dirs] || [])
    action :create
    only_if "getent passwd #{u[:id]}"
  end
end
