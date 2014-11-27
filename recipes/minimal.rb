user "masaki" do
  comment "Masaki Matsushita"
end

group "sudo" do
  members "masaki"
end

sudo "sudo" do
  group "sudo"
  nopasswd true
end

directory "/home/masaki" do
  mode 0700
  owner "masaki"
end

directory "/home/masaki/.ssh" do
  mode 0700
  owner "masaki"
end

remote_file "/home/masaki/.ssh/authorized_keys" do
  source "https://github.com/Glasssaga.keys"
  mode 0600
  owner "masaki"
end

if platform_family?("debian")
  file "/etc/apt/sources.list" do
    _file = Chef::Util::FileEdit.new(path)
    _file.search_file_replace("us.archive.ubuntu.com", "ftp.jaist.ac.jp")
    _file.search_file_replace("jp.archive.ubuntu.com", "ftp.jaist.ac.jp")
    _file.search_file_replace("archive.ubuntu.com", "ftp.jaist.ac.jp")
    _file.search_file_replace("security.ubuntu.com", "ftp.jaist.ac.jp")
    content _file.send(:editor).lines.join
    notifies :run, 'execute[apt-get update]', :immediately
  end

  execute "apt-get update" do
    action :nothing
  end

  apt_package "language-pack-ja"

  link "/etc/localtime" do
    to "/usr/share/zoneinfo/Japan"
  end
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
