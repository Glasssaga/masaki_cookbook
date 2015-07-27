include_recipe "users"

remote_file "/etc/apt/sources.list" do
  source "sources.list"
end

if platform_family?("mac_os_x")
  package "readline"
  package "python"
else
  include_recipe "xml"
  include_recipe "readline"
  include_recipe "ncurses"
  include_recipe "python"
  include_recipe "java"
end

include_recipe "postgresql::client"
include_recipe "imagemagick"
include_recipe "sqlite"
include_recipe "erlang::package"

mysql_client "default"

if platform_family?("rhel")
  #yum_package "php"
  yum_package "perl"
  yum_package "nc"
end

case node[:platform]
when "amazon"
  yum_package "php"
  #TODO: install lv
when "mac_os_x"
  #package "perl-build"
  include_recipe "lv"
else
  include_recipe "php"
  include_recipe "composer"
  include_recipe "perl"
  include_recipe "lv"
end

homebrew_tap "homebrew/dupes" if platform?("mac_os_x")

package "cmake"
package "binutils"
package "wget"
package "curl"
package "subversion"
package "nodejs"
package "npm"
package "tmux"
package "vim"
package "htop"
package "curl"
package "nmap"
package "git-review"

unless platform?("mac_os_x")
  package "iotop"
end

case node[:platform_family]
when "rhel"
  yum_package "libyaml-devel"
  yum_package "bzip2-devel"
  yum_package "zlib-devel"
when "mac_os_x"
  package "libyaml"
else
  package "libssl-dev"
  package "libyaml-dev"
  package "libbz2-dev"
  package "zlib1g-dev"
  package "libevent-dev"
end

if platform_family?("debian")
  apt_package "sysv-rc-conf"
  apt_package "locales"
end

if platform_family?("rhel")
  file "/etc/sysconfig/i18n" do
    content <<-EOS
LANG="ja_JP.UTF-8"
    EOS
  end
end

# japanese manpages
case node[:platform_family]
when "rhel"
  yum_package "man-pages-ja"
when "debian"
  apt_package "manpages-ja"
end

# change shell of root
execute "chsh -s /bin/zsh" do
  not_if "test $SHELL = '/bin/zsh'"
end

ssh_known_hosts_entry "github.com" unless platform?("mac_os_x")

directory node[:download_dir] do
  owner node[:user]
end

#TODO: NeoBundleInstall

INSTALL_RUBY_VERSION = "2.2.1"
ruby_binary_dir = INSTALL_RUBY_VERSION.match(/^(\d\.\d)\.\d$/)[1] # e.g. "2.1"

remote_file File.join(node[:download_dir], "ruby-#{INSTALL_RUBY_VERSION}.tar.bz2") do
  source "https://ftp.ruby-lang.org/pub/ruby/#{ruby_binary_dir}/ruby-#{INSTALL_RUBY_VERSION}.tar.bz2"
  owner node[:user]
  notifies :run, "bash[build ruby]"
end

bash "build ruby" do
  code <<-EOS
tar xjf ruby-#{INSTALL_RUBY_VERSION}.tar.bz2 && \
cd ruby-#{INSTALL_RUBY_VERSION} && \
./configure --disable-install-doc && \
make -j #{node[:cpu][:total]}
  EOS
  cwd node[:download_dir]
  user node[:user]
  notifies :run, "bash[install ruby]"
  action :nothing
end

bash "install ruby" do
  code "make install"
  cwd File.join(node[:download_dir], "ruby-#{INSTALL_RUBY_VERSION}")
  notifies :run, "execute[rubygems-update]"
  action :nothing
end

# force use of system gem, not chef_gem
GEM_PATH = "/usr/local/bin/gem"

execute "rubygems-update" do
  command "#{GEM_PATH} update --system"
  notifies :run, "execute[gem-update]"
  action :nothing
end

execute "gem-update" do
  command "#{GEM_PATH} update"
  action :nothing
end
