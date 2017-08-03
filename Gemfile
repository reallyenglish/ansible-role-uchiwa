source "https://rubygems.org"

# XXX workaround checksum mismatch
# https://github.com/lostisland/faraday_middleware/issues/165
# https://github.com/rubygems/rubygems.org/issues/1564 (the real problem)
gem "faraday_middleware", "< 0.12.1"
gem "infrataster", "~> 0.3.2", git: "https://github.com/trombik/infrataster.git", branch: "reallyenglish"
gem "kitchen-ansible", "~> 0.40.1", git: "https://github.com/trombik/kitchen-ansible.git", branch: "freebsd_support" # use patched kitchen-ansible
gem "kitchen-sync", "~> 2.1.1", git: "https://github.com/trombik/kitchen-sync.git", branch: "without_full_path_to_rsync"
gem "kitchen-vagrant", "~> 0.20.0"
gem "kitchen-verifier-serverspec", "~> 0.3.0"
gem "kitchen-verifier-shell", "~> 0.2.0"
gem "rack", "~> 1.6.4" # rack 2.x requires ruby >= 2.2.2
gem "rake", "~> 11.1.2"
gem "rspec", "~> 3.4.0"
gem "rubocop", "~> 0.47.1"
gem "serverspec", "~> 2.37.2"
gem "specinfra", ">= 2.63.2" # OpenBSD's `port` is fixed in this version
gem "test-kitchen", "~> 1.6.0"
