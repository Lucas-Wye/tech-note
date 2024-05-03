#!/bin/bash

docker run -it \
  -p 12289:5901 \
  -v $HOME/path:/work \
  --hostname lizhen \
  --mac-address 02:42:ac:11:00:02 \
  phyzli/ubuntu18.04_xfce4_vnc4server_synopsys

# vncserver -geometry 1920x1080 :1
# vnc password：zhenchen


# use docker compose 
# docker exec -it name /bin/bash
