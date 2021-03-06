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
| `uchiwa_flags` | dict of variables used in start-up scripts, such as `/etc/default/uchiwa` (see below) | `{}` |
| `uchiwa_flags_default` | default of `uchiwa_flags` | `{{ __uchiwa_flags_default }}` |
| `uchiwa_config` | YAML representation of `uchiwa.json` | `{}` |
| `uchiwa_config_fragments` | YAML representation of optional files under `uchiwa_config_fragments_dir` | `{}` |
| `uchiwa_config_fragments_dir` | | `{{ uchiwa_conf_dir }}/dashboard.d` |
| `uchiwa_privatekey` | content of `privatekey` | `""` |
| `uchiwa_privatekey_mode` | file mode of `privatekey` | `0400` |
| `uchiwa_privatekey_path` | path to `privatekey` file | `{{ uchiwa_conf_dir }}/keys/uchiwa.rsa` |
| `uchiwa_publickey` | content of `publickey` | `""` |
| `uchiwa_publickey_mode` | file mode of `publickey` | `0444` |
| `uchiwa_publickey_path` | path to `publickey` file | `{{ uchiwa_conf_dir }}/keys/uchiwa.rsa.pub` |
| `uchiwa_include_role_x509_certificate` | include and execute `reallyenglish.x509-certificate` during the play when `yes` (see below) | `no` |

## `uchiwa_flags`

This variable is a dict of variables of startup configuration files, such as
files under `/etc/default`, `/etc/sysconfig`, and `/etc/rc.conf.d`. It is
assumed that the files are `source`d by startup mechanism with `sh(1)`. A key
in the dict is name of the variable in the file, and the value of the key is
value of the variable. The variable is combined with a variable whose name is
same as this variable, but postfixed with `_default` (explained below) and the
result creates the startup configuration file, usually a file consisting of
lines of `key="value"` under appropriate directory for the platform.

When the platform is OpenBSD, the above explanation does not apply. In this
case, the only valid key is `flags` and the value of it is passed to
`daemon_flags` described in [`rc.conf(5)`](http://man.openbsd.org/rc.conf),
where `daemon` is the name of one of the `rc.d(8)` daemon control scripts.

## `uchiwa_flags_default`

This variable is a dict of keys and values derived from upstream's default
configuration, and is supposed to be a constant unless absolutely necessary. By
default, the role creates a startup configuration file for each platform with
this variable, identical to default one.

When the platform is OpenBSD, the variable has a single key, `flags` and its
value is empty string.

## `uchiwa_include_role_x509_certificate`

When `yes`, this variable includes and execute
[`reallyenglish.x509`](https://github.com/reallyenglish/ansible-role-x509-certificate)
during the play, which makes it possible to manage certificates without ugly
hacks. This is only supported in `ansible` version _at least_ 2.2 and later.

Known supported platforms:

| platform | `ansible version` |
|----------|-------------------|
| CentOS   | 2.3.1.0           |
| FreeBSD  | 2.3.1.0           |
| Ubuntu   | 2.3.1.0-1ppa~xenial |
| Ubuntu   | 2.3.1.0-1ppa~trusty |

## Debian

| Variable | Default |
|----------|---------|
| `__uchiwa_user` | `uchiwa` |
| `__uchiwa_group` | `uchiwa` |
| `__uchiwa_service` | `uchiwa` |
| `__uchiwa_conf_dir` | `/etc/sensu` |
| `__uchiwa_public_dir` | `/opt/uchiwa/src/public` |
| `__uchiwa_flags_default` | `{}` |

## FreeBSD

| Variable | Default |
|----------|---------|
| `__uchiwa_user` | `uchiwa` |
| `__uchiwa_group` | `uchiwa` |
| `__uchiwa_service` | `uchiwa` |
| `__uchiwa_conf_dir` | `/usr/local/etc/uchiwa` |
| `__uchiwa_public_dir` | `/usr/local/share/uchiwa/public` |
| `__uchiwa_flags_default` | `{"uchiwa_user"=>"{{ uchiwa_user }}", "uchiwa_group"=>"{{ uchiwa_group }}", "uchiwa_config"=>"{{ uchiwa_conf_file }}", "uchiwa_logfile"=>"{{ uchiwa_log_dir }}/uchiwa.log", "uchiwa_publicdir"=>"{{ uchiwa_public_dir }}"}` |

## RedHat

| Variable | Default |
|----------|---------|
| `__uchiwa_user` | `uchiwa` |
| `__uchiwa_group` | `uchiwa` |
| `__uchiwa_service` | `uchiwa` |
| `__uchiwa_conf_dir` | `/etc/sensu` |
| `__uchiwa_public_dir` | `/opt/uchiwa/src/public` |
| `__uchiwa_flags_default` | `{}` |

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
    x509_certificate:
      - name: uchiwa
        state: present
        public:
          path: "{{ uchiwa_conf_dir }}/uchiwa.pem"
          key: |
            -----BEGIN CERTIFICATE-----
            MIIDOjCCAiICCQDaGChPypIR9jANBgkqhkiG9w0BAQUFADBfMQswCQYDVQQGEwJB
            VTETMBEGA1UECAwKU29tZS1TdGF0ZTEhMB8GA1UECgwYSW50ZXJuZXQgV2lkZ2l0
            cyBQdHkgTHRkMRgwFgYDVQQDDA9mb28uZXhhbXBsZS5vcmcwHhcNMTcwNzE4MDUx
            OTAxWhcNMTcwODE3MDUxOTAxWjBfMQswCQYDVQQGEwJBVTETMBEGA1UECAwKU29t
            ZS1TdGF0ZTEhMB8GA1UECgwYSW50ZXJuZXQgV2lkZ2l0cyBQdHkgTHRkMRgwFgYD
            VQQDDA9mb28uZXhhbXBsZS5vcmcwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
            AoIBAQDZ9nd1isoGGeH4OFbQ6mpzlldo428LqEYSH4G7fhzLMKdYsIqkMRVl1J3s
            lXtsMQUUP3dcpnwFwKGzUvuImLHx8McycJKwOp96+5XD4QAoTKtbl59ZRFb3zIjk
            Owd94Wp1lWvptz+vFTZ1Hr+pEYZUFBkrvGtV9BoGRn87OrX/3JI9eThEpksr6bFz
            QvcGPrGXWShDJV/hTkWxwRicMMVZVSG6niPusYz2wucSsitPXIrqXPEBKL1J8Ipl
            8dirQLsH02ZZKcxGctEjlVgnpt6EI+VL6fs5P6A45oJqWmfym+uKztXBXCx+aP7b
            YUHwn+HV4qzZQld80PSTk6SS3hMXAgMBAAEwDQYJKoZIhvcNAQEFBQADggEBAKgf
            x3K9GHDK99vsWN8Ej10kwhMlBWBGuM0wkhY0fbxJ0gW3sflK8z42xMc2dhizoYsY
            sLfN0aylpN/omocl+XcYugLHnW2q8QdsavWYKXqUN0neIMr/V6d1zXqxbn/VKdGr
            CD4rJwewBattCIL4+S2z+PKr9oCrxjN4i3nujPhKv/yijhrtV+USw1VwuFqsYaqx
            iScC13F0nGIJiUVs9bbBwBKn1c6GWUHHiFCZY9VJ15SzilWAY/TULsRsHR53L+FY
            mGfQZBL1nwloDMJcgBFKKbG01tdmrpTTP3dTNL4u25+Ns4nrnorc9+Y/wtPYZ9fs
            7IVZsbStnhJrawX31DQ=
            -----END CERTIFICATE-----
        secret:
          path: "{{ uchiwa_conf_dir }}/uchiwa.key"
          owner: "{{ uchiwa_user }}"
          group: "{{ uchiwa_group }}"
          mode: "0640"
          key: |
            -----BEGIN RSA PRIVATE KEY-----
            MIIEowIBAAKCAQEA2fZ3dYrKBhnh+DhW0Opqc5ZXaONvC6hGEh+Bu34cyzCnWLCK
            pDEVZdSd7JV7bDEFFD93XKZ8BcChs1L7iJix8fDHMnCSsDqfevuVw+EAKEyrW5ef
            WURW98yI5DsHfeFqdZVr6bc/rxU2dR6/qRGGVBQZK7xrVfQaBkZ/Ozq1/9ySPXk4
            RKZLK+mxc0L3Bj6xl1koQyVf4U5FscEYnDDFWVUhup4j7rGM9sLnErIrT1yK6lzx
            ASi9SfCKZfHYq0C7B9NmWSnMRnLRI5VYJ6behCPlS+n7OT+gOOaCalpn8pvris7V
            wVwsfmj+22FB8J/h1eKs2UJXfND0k5Okkt4TFwIDAQABAoIBAHmXVOztj+X3amfe
            hg/ltZzlsb2BouEN7okNqoG9yLJRYgnH8o/GEfnMsozYlxG0BvFUtnGpLmbHH226
            TTfWdu5RM86fnjVRfsZMsy+ixUO2AaIG444Y4as7HuKzS2qd5ZXS1XB8GbrCSq7r
            iF/4tscQrzoG0poQorP9f9y60+z3R45OX3QMVZxP4ZzxXAulHGnECERjLHM5QzTX
            ALV9PHkTRNd1tm9FSJWWGNO5j4CGxFsPL1kdMyvrC7TkYiIiCQ/dd2CIfQyWwyKc
            8cHBKnzon0ugr0xlf2B0C7RTXrGAcuBC0yyaLuQTFkocUofgDIFghItH8O8xvvAG
            j8HYOwECgYEA9uMLtm2C8SiWFuafrF/pPWvhkBtEHA2g22M29CANrVv1jCEVMti/
            7r53fd328/nVxtashnSFz7a3l3s9d9pTR/rk/rNpVS2i7JGvCXXE3DeoD6Zf4utD
            MLEs2bI0KabdamIywc77CkVj9WUKd53tlcdcn7AsHwESU4Zjk08ie0kCgYEA4gIa
            R+a9jmKEk9l5Gn7jroxDJdI0gEfuA7It5hshEDcSvjF+Fs5+1tVgfBI1Mx4/0Eaj
            6E57Ln3WFKPJKuG0HwLNanZcqLFgiC/7ANbyKxfONPVrqC2TClImBhkQ74BLafZg
            yY8/N/g/5RIMpYvQ9snBRsah9G2cBfuPTHjku18CgYBHylPQk12dJJEoTZ2msSkQ
            jDtF/Te79JaO1PXY3S08+N2ZBtG0PGTrVoVGm3HBFif8rtXyLxXuBZKzQMnp/Rl0
            d9d43NDHTQLwSZidZpp88s4y5s1BHeom0Y5aK0CR0AzYb3+U7cv/+5eKdvwpNkos
            4JDleoQJ6/TZRt3TqxI6yQKBgA8sdPc+1psooh4LC8Zrnn2pjRiM9FloeuJkpBA+
            4glkqS17xSti0cE6si+iSVAVR9OD6p0+J6cHa8gW9vqaDK3IUmJDcBUjU4fRMNjt
            lXSvNHj5wTCZXrXirgraw/hQdL+4eucNZwEq+Z83hwHWUUFAammGDHmMol0Edqp7
            s1+hAoGBAKCGZpDqBHZ0gGLresidH5resn2DOvbnW1l6b3wgSDQnY8HZtTfAC9jH
            DZERGGX2hN9r7xahxZwnIguKQzBr6CTYBSWGvGYCHJKSLKn9Yb6OAJEN1epmXdlx
            kPF7nY8Cs8V8LYiuuDp9UMLRc90AmF87rqUrY5YP2zw6iNNvUBKs
            -----END RSA PRIVATE KEY-----
    uchiwa_include_role_x509_certificate: yes
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
        auth:
          privatekey: "{{ uchiwa_privatekey_path }}"
          publickey: "{{ uchiwa_publickey_path }}"
        ssl:
          certfile: "{{ uchiwa_conf_dir }}/uchiwa.pem"
          keyfile: "{{ uchiwa_conf_dir }}/uchiwa.key"
    # openssl genrsa -out uchiwa.rsa 2048
    # openssl rsa -in uchiwa.rsa -pubout > uchiwa.rsa.pub
    uchiwa_flags:
      "# foo": bar
    uchiwa_publickey: |
      -----BEGIN PUBLIC KEY-----
      MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwU+ZfaKjXxFQq8WNUgai
      IKOo7JN/03P5d0ZrVLSDXeQ5F5MGjtKatobgNiA385ISVAt6d2QoZR8QQhxAwcKS
      ycPXlNvrGRNLzwUmzWD/ccFkXGxs3DvnyFF+ZuRNT/fDxavRhv4fUMO1z75Bn6s1
      dba500FZuWJyHXp318O0+hO6VN6nnU16c6kudNUoCIrHVxLshW65TXBcsX556vS6
      f74koZC04Z5kGY/ha/T7lJjDWTlNreI4mv+sbfaJ2kyia47u4xnsup9dkd+BSjfU
      ECkXhEBkp7UpYeGfxcCCROZGyP5obcRcjPABK1qHMhatqD7oVicXedPs3RyvzvDJ
      KwIDAQAB
      -----END PUBLIC KEY-----
    uchiwa_privatekey_path: "{{ uchiwa_conf_dir }}/privatekeys/uchiwa.rsa"
    uchiwa_privatekey_mode: 0440
    uchiwa_privatekey: |
      -----BEGIN RSA PRIVATE KEY-----
      MIIEowIBAAKCAQEAwU+ZfaKjXxFQq8WNUgaiIKOo7JN/03P5d0ZrVLSDXeQ5F5MG
      jtKatobgNiA385ISVAt6d2QoZR8QQhxAwcKSycPXlNvrGRNLzwUmzWD/ccFkXGxs
      3DvnyFF+ZuRNT/fDxavRhv4fUMO1z75Bn6s1dba500FZuWJyHXp318O0+hO6VN6n
      nU16c6kudNUoCIrHVxLshW65TXBcsX556vS6f74koZC04Z5kGY/ha/T7lJjDWTlN
      reI4mv+sbfaJ2kyia47u4xnsup9dkd+BSjfUECkXhEBkp7UpYeGfxcCCROZGyP5o
      bcRcjPABK1qHMhatqD7oVicXedPs3RyvzvDJKwIDAQABAoIBACpi68LygGP+BfRE
      EuKjdbU2bXnCNcsFqPOQS0R9eDiELEiRAmUapLXVCSCVG++aXc5z3dyD55+UmhoE
      2+YgZdM7z+9h8UDETGEOPh3WYOxufTUOySfZMs9nnxGsiY85QoH7VKwG2JL69sig
      bP83qTcwY7qAn83YWjFAgzqaPPqAKo3ZiLl1OJyK6SplJy/mL130q4i381CgvItZ
      DBG42g2jhljcOkjrEAXql1eswYgv//wKIeWoYXwlP5gn4yG5gNzy1jSUvtw/SeRG
      LXPrHT6y1HJBRCJk0AjjPtgL3cNep92Qy9Gj0C8hbtL5rdleK6NWLOmgT97MAzc8
      0VeU/FECgYEA/DOL/WQuLMWb3RRP0oRAVX76WLtY/0ZB8Q9TgeugaxQO4SHofSQC
      6Q7ty69qlxHF84b4bz538Ad6N8w6fPyT09r2dKFjcosStFm4NyD2X5FFoHn0kh/H
      Uv8nVzWP2tgAqurKAHYMwShFXsnY3uikkMzDfnajn3PYOgyvwS81xCcCgYEAxDj6
      wYsAIEqwZo2xl/uyiEnTW5OUmo6AmPP7KfjmShpijZDtY+/SQzE1kd2srr8nLhjV
      e1o/AjKzvkoF9YkXAGcgva25saTEz6LT672ShxkFitS/7tO7fCQINefl3tfivIlb
      wJtV8us2IC6wfvAM3t7MicPqDlNfiG2WgHMUoV0CgYEA3bNGjXJicPMph9fSL6IY
      l8+urQ/MNWOCljE93IjQlTClv9y57kAY2t1HxvUmQzTZibGNdOU6M+Ou2ZwLklHK
      dcMXQgGZVVjSEX6JRNUSH4Kp7V8n0shixSANaklocx3MwHLzLiKYJbiL+r5/ibyC
      5dNKy0HppkMEwkriuXUR06MCgYAyznIW9O+2bMBZ/WwzZwdmBH+GYaMDlcw0TlAF
      IR43p7dG4nSlAK6XmUE+oIAaywHRDLsR8l8IKaqipbX/Sly7TPiMRFQla/1NqeJn
      UrGC63ak6Ms9gnM0BHxfwMijN5DMsmAgcdgCSua71Hr8kxkyB8w8C48p4GqG/6EN
      Zz67PQKBgHsqw8SmNevT5tDezXG8B0Vs9xbO3SDJj5IDbI2yQ+4i7k3MznngPjYx
      63qvMaG1nnUqeaagGCbq5POFhVPJOFr2hl8eU6hb3iwxjcH5gHnLRGbMq8YNVDDv
      62ifBFXVQ8mMOCCtEwyQSGjeXiEGjDommzQN/xT4O3rDztgGMH6+
      -----END RSA PRIVATE KEY-----
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
