git "/usr/src/oh-my-zsh" do
  repository "https://github.com/robbyrussell/oh-my-zsh.git"
  reference "master"
  action :sync
end

search( :users, "shell:*zsh" ).each do |u|

  theme = data_bag_item( "users", u["id"])["oh-my-zsh-theme"]

  link "#{u["home_dir"]}/.oh-my-zsh" do
    to "/usr/src/oh-my-zsh"
    only_if { File.exist?(u["home_dir"]) }
    not_if { File.exist?("#{u["home_dir"]}/.oh-my-zsh") }
  end

  template "#{u["home_dir"]}/.zshrc" do
    source "zshrc.erb"
    owner u[:id]
    group u[:groups].first
    variables( :theme => ( theme || node[:ohmyzsh][:theme] ), :disable_auto_update => true )
    action :create_if_missing
    only_if { File.exist?(u["home_dir"]) }
  end
end
