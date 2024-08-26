install_nginx:
  pkg.installed:
    - name: nginx

start_nginx:
  service.running:
    - name: nginx
    - enable: True
    - require:
      - pkg: install_nginx

default.conf:
  file.managed:
    - name: /etc/nginx/conf.d/default.conf
    - source: salt://{{tpldir}}/configs/default.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja

#install_nginx:
#  pkg.removed:
#    - name: nginx

#stop_nginx_service:
#  service.dead:
#    - name: nginx
#    - enable: False