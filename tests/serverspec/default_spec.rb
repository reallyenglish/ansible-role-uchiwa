require "spec_helper"
require "serverspec"

package = "uchiwa"
service = "uchiwa"
config_dir = "/etc/uchiwa"
user    = "uchiwa"
group   = "uchiwa"
ports   = [3000]
log_dir = "/var/log/uchiwa"
public_dir = "/usr/local/share/uchiwa/public"
default_user = "root"
default_group = "root"

case os[:family]
when "freebsd"
  config_dir = "/usr/local/etc/uchiwa"
  default_group = "wheel"
end

config  = "#{config_dir}/uchiwa.json"

describe package(package) do
  it { should be_installed }
end

describe file(config) do
  it { should exist }
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by default_user }
  it { should be_grouped_into default_group }
  its(:content_as_json) { should include("sensu") }
  its(:content_as_json) { should include("sensu" => include("name" => "Site 1", "host" => "localhost", "port" => 4567)) }
  its(:content_as_json) { should include("uchiwa" => include("host" => "0.0.0.0")) }
  its(:content_as_json) { should include("uchiwa" => include("port" => 3000)) }
  its(:content_as_json) { should include("uchiwa" => include("users" => include("name" => "admin", "password" => "password", "accessToken" => "vFzX6rFDAn3G9ieuZ4ZhN-XrfdRow4Hd5CXXOUZ5NsTw4h3k3l4jAw__", "readonly" => false))) }
  its(:content_as_json) { should include("uchiwa" => include("users" => include("name" => "guest", "password" => "password", "accessToken" => "hrKMW3uIt2RGxuMIoXQ-bVp-TL1MP4St5Hap3KAanMxI3OovFV48ww__", "readonly" => true))) }
end

describe file(log_dir) do
  it { should exist }
  it { should be_directory }
  it { should be_mode 755 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

case os[:family]
when "freebsd"
  describe file("/etc/rc.conf.d/uchiwa") do
    it { should exist }
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
    its(:content) { should match(/^uchiwa_user="#{user}"$/) }
    its(:content) { should match(/^uchiwa_group="#{group}"$/) }
    its(:content) { should match(/^uchiwa_config="#{Regexp.escape(config)}"$/) }
    its(:content) { should match(/^uchiwa_logfile="#{Regexp.escape(log_dir)}\/uchiwa\.log"$/) }
    its(:content) { should match(/^uchiwa_publicdir="#{Regexp.escape(public_dir)}"$/) }
  end
end

describe service(service) do
  it { should be_running }
  it { should be_enabled }
end

ports.each do |p|
  describe port(p) do
    it { should be_listening }
  end
end
