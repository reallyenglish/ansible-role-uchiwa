require "spec_helper"
require "serverspec"

package = "uchiwa"
service = "uchiwa"
config_dir = "/etc/sensu"
user    = "uchiwa"
group   = "uchiwa"
ports   = [3000]
log_dir = "/var/log/uchiwa"
log_file = "#{log_dir}/uchiwa.log"
public_dir = "/opt/uchiwa/src/public"
default_user = "root"
default_group = "root"

case os[:family]
when "freebsd"
  config_dir = "/usr/local/etc/uchiwa"
  default_group = "wheel"
  public_dir = "/usr/local/share/uchiwa/public"
end

config = "#{config_dir}/uchiwa.json"
private_key_path = "#{config_dir}/privatekeys/uchiwa.rsa"
public_key_path = "#{config_dir}/keys/uchiwa.rsa.pub"

describe package(package) do
  it { should be_installed }
end

describe file(config) do
  it { should exist }
  it { should be_file }
  it { should be_mode os[:family] == "freebsd" ? 644 : 664 }
  it { should be_owned_by os[:family] == "redhat" ? user : default_user }
  it { should be_grouped_into os[:family] == "redhat" ? user : default_group }
  its(:content_as_json) { should include("sensu") }
  its(:content_as_json) { should include("sensu" => include("name" => "Site 1", "host" => "localhost", "port" => 4567)) }
  its(:content_as_json) { should include("uchiwa" => include("host" => "0.0.0.0")) }
  its(:content_as_json) { should include("uchiwa" => include("port" => 3000)) }
  its(:content_as_json) { should include("uchiwa" => include("users" => include("name" => "admin", "password" => "password", "accessToken" => "vFzX6rFDAn3G9ieuZ4ZhN-XrfdRow4Hd5CXXOUZ5NsTw4h3k3l4jAw__", "readonly" => false))) }
  its(:content_as_json) { should include("uchiwa" => include("users" => include("name" => "guest", "password" => "password", "accessToken" => "hrKMW3uIt2RGxuMIoXQ-bVp-TL1MP4St5Hap3KAanMxI3OovFV48ww__", "readonly" => true))) }
end

[public_key_path, private_key_path].each do |f|
  describe file(File.dirname(f)) do
    it { should exist }
    it { should be_directory }
    it { should be_mode 755 }
    it { should be_owned_by user }
    it { should be_grouped_into group }
  end
end

describe file(private_key_path) do
  it { should exist }
  it { should be_file }
  it { should be_mode 440 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
  its(:content) { should match(/^-----BEGIN RSA PRIVATE KEY-----$/) }
  its(:content) { should match(/^#{Regexp.escape("MIIEowIBAAKCAQEAwU+ZfaKjXxFQq8WNUgaiIKOo7JN/03P5d0ZrVLSDXeQ5F5MG")}$/) }
  its(:content) { should match(/^-----END RSA PRIVATE KEY-----$/) }
end

describe file(public_key_path) do
  it { should exist }
  it { should be_file }
  it { should be_mode 444 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
  its(:content) { should match(/^-----BEGIN PUBLIC KEY-----$/) }
  its(:content) { should match(/^#{Regexp.escape("MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwU+ZfaKjXxFQq8WNUgai")}$/) }
  its(:content) { should match(/^-----END PUBLIC KEY-----$/) }
end

describe file(log_dir) do
  it { should exist }
  it { should be_directory }
  it { should be_mode 755 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

case os[:family]
when "redhat"
  describe file("/etc/sysconfig/uchiwa") do
    it { should exist }
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
    its(:content) { should match(/^# foo="bar"$/) }
  end
when "ubuntu"
  describe file("/etc/default/uchiwa") do
    it { should exist }
    it { should be_file }
    it { should be_mode 664 }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
    its(:content) { should match(/^# foo="bar"$/) }
  end
when "freebsd"
  describe file("/etc/rc.conf.d/uchiwa") do
    it { should exist }
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
    its(:content) { should match(/^# foo="bar"$/) }
    its(:content) { should match(/^uchiwa_user="#{user}"$/) }
    its(:content) { should match(/^uchiwa_group="#{group}"$/) }
    its(:content) { should match(/^uchiwa_config="#{Regexp.escape(config)}"$/) }
    its(:content) { should match(/^uchiwa_logfile="#{Regexp.escape(log_file)}"$/) }
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

describe command("echo | openssl s_client -connect 127.0.0.1:3000 -showcerts") do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should match(/verify error:num=18:self signed certificate/) }
  its(:stdout) { should match(/#{Regexp.escape("issuer=/C=AU/ST=Some-State/O=Internet Widgits Pty Ltd/CN=foo.example.org")}/) }
end
