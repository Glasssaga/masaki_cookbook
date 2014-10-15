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

# timezone-ii
default[:tz] = "Asia/Tokyo"

# ntp
default[:ntp][:servers] = ["ntp.nict.jp", "ntp1.jst.mfeed.ad.jp", "ntp2.jst.mfeed.ad.jp", "ntp3.jst.mfeed.ad.jp"]
