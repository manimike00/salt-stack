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