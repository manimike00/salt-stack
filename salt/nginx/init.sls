install_nginx:
  pkg.installed:
    - name: nginx

#install_nginx:
#  pkg.removed:
#    - name: nginx

#stop_nginx_service:
#  service.dead:
#    - name: nginx
#    - enable: False

start_nginx:
  service.running:
    - name: nginx
    - enable: True
    - require:
      - pkg: install_nginx