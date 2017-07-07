# ansible-role-uchiwa

Manages `uchiwa`, dashboard for the Sensu monitoring framework.

# Requirements

None

# Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `uchiwa_user` | user of `uchiwa` | `{{ __uchiwa_user }}` |
| `uchiwa_group` | group of `uchiwa` | `{{ __uchiwa_group }}` |
| `uchiwa_log_dir` | path to log directory | `/var/log/uchiwa` |
| `uchiwa_public_dir` | path to public directory | `{{ __uchiwa_public_dir }}` |
| `uchiwa_service` | name of `uchiwa` service | `{{ __uchiwa_service }}` |
| `uchiwa_conf_dir` | path to configuration directory | `{{ __uchiwa_conf_dir }}` |
| `uchiwa_conf_file` | path to `uchiwa.json` | `{{ uchiwa_conf_dir }}/uchiwa.json` |
| `uchiwa_flags` | not yet used | `""` |
| `uchiwa_config` | YAML representation of `uchiwa.json` | `{}` |
| `uchiwa_config_fragments` | YAML representation of optional files under `uchiwa_config_fragments_dir` | `{}` |
| `uchiwa_config_fragments_dir` | | `{{ uchiwa_conf_dir }}/dashboard.d` |


## FreeBSD

| Variable | Default |
|----------|---------|
| `__uchiwa_user` | `uchiwa` |
| `__uchiwa_group` | `uchiwa` |
| `__uchiwa_service` | `uchiwa` |
| `__uchiwa_conf_dir` | `/usr/local/etc/uchiwa` |
| `__uchiwa_public_dir` | `/usr/local/share/uchiwa/public` |

# Dependencies

None

# Example Playbook

```yaml
- hosts: localhost
  roles:
    - name: reallyenglish.apt-repo
      when: ansible_os_family == 'Debian'
    - name: reallyenglish.redhat-repo
      when: ansible_os_family == 'RedHat'
    - name: reallyenglish.language-ruby
      when: ansible_os_family == 'OpenBSD'
    - ansible-role-uchiwa
  vars:
    redhat_repo:
      sensu:
        baseurl: https://sensu.global.ssl.fastly.net/yum/$releasever/$basearch
        gpgcheck: no
        enabled: yes
    apt_repo_keys_to_add:
      - https://sensu.global.ssl.fastly.net/apt/pubkey.gpg
    apt_repo_enable_apt_transport_https: yes
    apt_repo_to_add:
      - "deb https://sensu.global.ssl.fastly.net/apt {{ ansible_distribution_release }} main"
    uchiwa_config:
      sensu:
        - name: "Site 1"
          host: "localhost"
          port: 4567
      uchiwa:
        host: 0.0.0.0
        port: 3000
        users:
          - name: admin
            password: password
            # openssl rand -base64 40 |  tr -- '+=/' '-_~'
            accessToken: vFzX6rFDAn3G9ieuZ4ZhN-XrfdRow4Hd5CXXOUZ5NsTw4h3k3l4jAw__
            readonly: false
          - name: guest
            password: password
            accessToken: hrKMW3uIt2RGxuMIoXQ-bVp-TL1MP4St5Hap3KAanMxI3OovFV48ww__
            readonly: true
```

# License

```
Copyright (c) 2017 Tomoyuki Sakurai <tomoyukis@reallyenglish.com>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
```

# Author Information

Tomoyuki Sakurai <tomoyukis@reallyenglish.com>

This README was created by [qansible](https://github.com/trombik/qansible)
