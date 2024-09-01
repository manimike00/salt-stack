update_apt_cache:
  cmd.run:
    - name: apt update
    - unless: "test $(find /var/lib/apt/lists/ -mmin -60 | wc -l) -ne 0"

install_packages:
  pkg.installed:
    - pkgs:
      - curl
      - gnupg
      - gpg
      - apt-transport-https
    - require:
      - cmd: update_apt_cache

## Team RabbitMQ's main signing key
download_rabbitmq_gpg_key:
  cmd.run:
    - name: curl -1sLf "https://keys.openpgp.org/vks/v1/by-fingerprint/0A9AF2115F4687BD29803A206B73A36E6026DFCA" | gpg --dearmor | tee /usr/share/keyrings/com.rabbitmq.team.gpg
    - runas: root
    - shell: /bin/bash
    - output_loglevel: quiet
    - require:
      - pkg: install_packages

## Community mirror of Cloudsmith: modern Erlang repository
download_rabbitmq_erlang_gpg_key:
  cmd.run:
    - name: curl -1sLf https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-erlang.E495BB49CC4BBE5B.key | gpg --dearmor | tee /usr/share/keyrings/rabbitmq.E495BB49CC4BBE5B.gpg
    - runas: root
    - shell: /bin/bash
    - output_loglevel: quiet
    - require:
      - cmd: download_rabbitmq_gpg_key

## Community mirror of Cloudsmith: RabbitMQ repository
download_rabbitmq_server_gpg_key:
  cmd.run:
    - name: curl -1sLf https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-server.9F4587F226208342.key | gpg --dearmor | tee /usr/share/keyrings/rabbitmq.9F4587F226208342.gpg
    - runas: root
    - shell: /bin/bash
    - output_loglevel: quiet
    - require:
      - cmd: download_rabbitmq_erlang_gpg_key


# Create the RabbitMQ APT source list
rabbitmq_apt_source:
  file.managed:
    - name: /etc/apt/sources.list.d/rabbitmq.list
    - contents: |
        ## Provides modern Erlang/OTP releases
        ##
        deb [arch=amd64 signed-by=/usr/share/keyrings/rabbitmq.E495BB49CC4BBE5B.gpg] https://ppa1.rabbitmq.com/rabbitmq/rabbitmq-erlang/deb/ubuntu jammy main
        deb-src [signed-by=/usr/share/keyrings/rabbitmq.E495BB49CC4BBE5B.gpg] https://ppa1.rabbitmq.com/rabbitmq/rabbitmq-erlang/deb/ubuntu jammy main

        # another mirror for redundancy
        deb [arch=amd64 signed-by=/usr/share/keyrings/rabbitmq.E495BB49CC4BBE5B.gpg] https://ppa2.rabbitmq.com/rabbitmq/rabbitmq-erlang/deb/ubuntu jammy main
        deb-src [signed-by=/usr/share/keyrings/rabbitmq.E495BB49CC4BBE5B.gpg] https://ppa2.rabbitmq.com/rabbitmq/rabbitmq-erlang/deb/ubuntu jammy main

        ## Provides RabbitMQ
        ##
        deb [arch=amd64 signed-by=/usr/share/keyrings/rabbitmq.9F4587F226208342.gpg] https://ppa1.rabbitmq.com/rabbitmq/rabbitmq-server/deb/ubuntu jammy main
        deb-src [signed-by=/usr/share/keyrings/rabbitmq.9F4587F226208342.gpg] https://ppa1.rabbitmq.com/rabbitmq/rabbitmq-server/deb/ubuntu jammy main

        # another mirror for redundancy
        deb [arch=amd64 signed-by=/usr/share/keyrings/rabbitmq.9F4587F226208342.gpg] https://ppa2.rabbitmq.com/rabbitmq/rabbitmq-server/deb/ubuntu jammy main
        deb-src [signed-by=/usr/share/keyrings/rabbitmq.9F4587F226208342.gpg] https://ppa2.rabbitmq.com/rabbitmq/rabbitmq-server/deb/ubuntu jammy main
    - mode: 644
    - user: root
    - group: root
    - require:
      - cmd: download_rabbitmq_server_gpg_key

## Update package indices
update_apt_cache_rabbitmq:
  cmd.run:
    - name: apt update
    - unless: "test $(find /var/lib/apt/lists/ -mmin -60 | wc -l) -ne 0"
    - require:
      - file: rabbitmq_apt_source

# Install Erlang packages
install_erlang_packages:
  pkg.installed:
    - pkgs:
      - erlang-base
      - erlang-asn1
      - erlang-crypto
      - erlang-eldap
      - erlang-ftp
      - erlang-inets
      - erlang-mnesia
      - erlang-os-mon
      - erlang-parsetools
      - erlang-public-key
      - erlang-runtime-tools
      - erlang-snmp
      - erlang-ssl
      - erlang-syntax-tools
      - erlang-tftp
      - erlang-tools
      - erlang-xmerl    
    - require:
      - cmd: update_apt_cache_rabbitmq  