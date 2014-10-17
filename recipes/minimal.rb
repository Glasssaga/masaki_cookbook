include_recipe "ssh-keys"

log data_bag("users").to_s

if platform_family?("debian")
  file "/etc/apt/sources.list" do
    _file = Chef::Util::FileEdit.new(path)
    _file.search_file_replace("us.archive.ubuntu.com", "ftp.jaist.ac.jp")
    _file.search_file_replace("jp.archive.ubuntu.com", "ftp.jaist.ac.jp")
    _file.search_file_replace("security.ubuntu.com", "ftp.jaist.ac.jp")
    content _file.send(:editor).lines.join
    notifies :run, 'execute[apt-get update]', :immediately
  end
end

execute "apt-get update" do
  action :nothing
end

sudo "sudo" do
  group "sudo"
  nopasswd true
end

=begin
# update
case node[:platform_family]
when "rhel"
  execute "yum update -y"
when "debian"
  execute "apt-get update && apt-get dist-upgrade -y"
when "mac_os_x"
  execute "brew update"
end
=end
