include_recipe "masaki::default"

package "gdb"
package "gnupg"
package "gnupg2"
package "s3cmd"
package "nkf"
package "ansible"
package "mercurial"
package "valgrind"

if platform?("mac_os_x")
  package "go"
else
  package "golang"
  package "gocode"
end

unless platform?("mac_os_x")
  package "clang" 
  package "git-svn"
  package "systemtap"
  package "systemtap-server"
  package "jwhois"
  package "hdparm"
end

if platform?("mac_os_x")
  execute "curl https://bootstrap.pypa.io/ez_setup.py -o - | python" do
    not_if "which easy_install"
  end
  easy_install_package "pip"
else
  package "python-setuptools" # for easy_install
  package "python-pip"
end

python_pip "awscli"
python_pip "cloudmonkey"
python_pip "boto"

case node[:platform_family]
when "rhel"
  yum_package "ctags"
  yum_package "jemalloc"
  yum_package "gperftools" # for tcmalloc etc.
  yum_package "glibc-utils" # for mtrace
  #XXX: gpg-agent is included in "gnupg" package.
when "mac_os_x"
  package "ctags"
  package "jemalloc"
  package "google-perftools"
  package "gpg-agent"
else
  package "exuberant-ctags"
  package "libjemalloc-dev"
  package "libgoogle-perftools-dev"
  #TODO: glibc-tools
  package "gnupg-agent"
end

unless platform?("centos")
  tmux_mem_cpu_load_path = File.join(Chef::Config[:file_cache_path], "tmux-mem-cpu-load")
  git tmux_mem_cpu_load_path do
    repository "https://github.com/thewtex/tmux-mem-cpu-load"
    notifies :run, "bash[build tmux-mem-cpu-load]"
  end

  bash "build tmux-mem-cpu-load" do
    code "cmake . && make && make install"
    cwd tmux_mem_cpu_load_path
    not_if "which tmux-mem-cpu-load"
    action :nothing
  end
end

dotfiles_path = File.join(node[:download_dir], "dotfiles")
git dotfiles_path do
  repository "https://github.com/Glasssaga/dotfiles" #TODO: use SSH
  enable_submodules true
  user node[:user]
  notifies :run, "execute[checkout master(dotfiles)]", :immediately
end

execute "checkout master(dotfiles)" do
  command "git checkout master"
  cwd dotfiles_path
  user node[:user]
  notifies :run, "bash[symlink]", :immediately
  action :nothing
end

bash "symlink" do
  cwd dotfiles_path
  code "./symlink.sh"
  environment "HOME" => node[:home]
  user node[:user]
  action :nothing
end

GEMS = %w{
bundler
rails
pry
pry-doc
nokogiri
execjs
unicorn
aws-sdk
rspec
serverspec
eventmachine
elasticsearch
knife-solo
therubyracer
fluentd
bunny
daemons
}

GEMS.each do |gem|
  gem_package gem
end
