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