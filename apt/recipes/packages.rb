require_recipe 'apt'

if node[:packages]
  node[:packages].each do |group, packages|
    packages.each do |name|
      package name
    end
  end
end
