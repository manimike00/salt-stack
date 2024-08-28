update_apt_cache:
  cmd.run:
    - name: apt update
    - unless: "test $(find /var/lib/apt/lists/ -mmin -60 | wc -l) -ne 0"

install_gpg_wget:
  pkg.installed:
    - pkgs:
      - gpg
      - wget
    - require:
      - cmd: update_apt_cache

add_hashicorp_gpg_key:
  cmd.run:
    - name: wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    - creates: /usr/share/keyrings/hashicorp-archive-keyring.gpg

verify_hashicorp_gpg_fingerprint:
  cmd.run:
    - name: gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint
    - require:
      - cmd: add_hashicorp_gpg_key

add_hashicorp_repo:
  cmd.run:
    - name: |
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
        https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
    - creates: /etc/apt/sources.list.d/hashicorp.list
    - require:
      - cmd: add_hashicorp_gpg_key

update_apt_cache_vault:
  cmd.run:
    - name: apt update
    - unless: "test $(find /var/lib/apt/lists/ -mmin -60 | wc -l) -ne 0"
    - require:
      - cmd: add_hashicorp_repo

#install_gpg_wget:
#  pkg.installed:
#    - pkgs:
#      - gpg
#      - wget
#    - require:
#      - cmd: update_apt_cache

#vault.hcl:
#  file.managed:
#    - name: /etc/vault.d/vault.hcl
#    - source: salt://{{tpldir}}/configs/vault.hcl
#    - user: vault
#    - group: vault
#    - mode: 644
#    - template: jinja