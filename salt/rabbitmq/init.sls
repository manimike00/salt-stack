update_apt_cache:
  cmd.run:
    - name: apt update
    - unless: "test $(find /var/lib/apt/lists/ -mmin -60 | wc -l) -ne 0"

install_gpg_wget:
  pkg.installed:
    - pkgs:
      - curl
      - gnupg
      - apt-transport-https
    - require:
      - cmd: update_apt_cache