#!/bin/bash

# Set up your .env file BEFORE running this script!!!
# export all variables from .env
set -a
source .env
set +a
# This is always going to complain about UID being a read-only variable. 
# However that is not a problem and it's necessary for UID to be defined in the .env so that docker-compose.yml can take it.
# Reminder to set the UID variable in .env if you haven't already. It needs to be the user you want to run docker as. Find what it should be by running "id -u" from that user's shell.

# Make users and group
sudo useradd bazarr -u $BAZARR_UID
sudo useradd prowlarr -u $PROWLARR_UID
sudo useradd qbittorrent -u $QBITTORRENT_UID
sudo useradd radarr -u $RADARR_UID
sudo useradd sabnzbd -u $SABNZBD_UID
sudo useradd sonarr -u $SONARR_UID

sudo groupadd mediacenter -g $MEDIACENTER_GID

# Adds current user to the mediacenter group. This is recommended so that you can still have access to files inside the ezarr folder structure for manual control.
# This is way better than just doing everything as root, especially on NFS shares. Also some services run as the default user anyway (Jellyfin, Tautulli).
sudo usermod -a -G mediacenter $USER
# When you add the user to the group the changes don't take effect immediately. 
# You can force them by running "sudo newgrp mediacenter" but that won't always work and it's better to just reboot after the script finishes running.

# adds all the service users to the group
sudo usermod -a -G mediacenter bazarr
sudo usermod -a -G mediacenter prowlarr
sudo usermod -a -G mediacenter qbittorrent
sudo usermod -a -G mediacenter radarr
sudo usermod -a -G mediacenter sabnzbd
sudo usermod -a -G mediacenter sonarr

# Make directories
sudo mkdir -p ${CONFIG_DIR}/{bazarr,jellyfin,prowlarr,qbittorrent,radarr,sabnzbd,seerr,sonarr}-config
sudo mkdir -p ${DATA_DIR}/data/{{media,torrents}/{movies,music,tv},usenet/{complete/{movies,music,tv},incomplete}}

# Set permissions
sudo chmod -R 775 ${DATA_DIR}/data/
sudo chmod -R 775 ${CONFIG_DIR}/
sudo chown -R $UID:mediacenter ${DATA_DIR}/data/
sudo chown -R $UID:mediacenter ${CONFIG_DIR}/
sudo chown -R bazarr:mediacenter ${CONFIG_DIR}/bazarr-config
sudo chown -R $UID:mediacenter ${CONFIG_DIR}/jellyfin-config
sudo chown -R prowlarr:mediacenter ${CONFIG_DIR}/prowlarr-config
sudo chown -R qbittorrent:mediacenter ${CONFIG_DIR}/qbittorrent-config
sudo chown -R radarr:mediacenter ${CONFIG_DIR}/radarr-config
sudo chown -R sabnzbd:mediacenter ${CONFIG_DIR}/sabnzbd-config
# The Seerr container uses 1000:1000
# See https://docs.seerr.dev/migration-guide/?kubernetes-values=old#config-folder-permissions
sudo chown -R $UID:$GID ${CONFIG_DIR}/seerr-config
sudo chown -R sonarr:mediacenter ${CONFIG_DIR}/sonarr-config

echo "Done! It is recommended to reboot now."
