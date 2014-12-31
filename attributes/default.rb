default[:user] = "masaki"
default[:home] = platform_family?("mac_os_x") ? "/Users/#{node[:user]}" : "/home/#{node[:user]}"

if platform?("mac_os_x")
  default[:download_dir] = File.join(node[:home], "Downloads")
else
  default[:download_dir] = File.join(node[:home], "download")
end

# sudo
default[:authorization][:sudo][:include_sudoers_d] = true

# java
default[:java][:jdk_version] = 7
