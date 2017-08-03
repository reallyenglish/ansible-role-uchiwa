require_relative "default_spec.rb"

describe command("echo | openssl s_client -connect 127.0.0.1:3000 -showcerts") do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should match(/verify error:num=18:self signed certificate/) }
  its(:stdout) { should match(/#{Regexp.escape("issuer=/C=AU/ST=Some-State/O=Internet Widgits Pty Ltd/CN=foo.example.org")}/) }
end
