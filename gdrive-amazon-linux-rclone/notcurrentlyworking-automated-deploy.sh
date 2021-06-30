#!/bin/bash
#installs
amazon-linux-extras install -y epel
yum install -y fuse 
curl https://rclone.org/install.sh | sudo bash

#Provision the plex.repo file so yum can install and update plex. 
cat <<EOF >> /etc/yum.repos.d/plex.repo
[PlexRepo]
name=PlexRepo
baseurl=https://downloads.plex.tv/repo/rpm/$basearch/
enabled=1
gpgkey=https://downloads.plex.tv/plex-keys/PlexSign.key
gpgcheck=1
EOF

echo '[PlexRepo]
name=PlexRepo
baseurl=https://downloads.plex.tv/repo/rpm/$basearch/
enabled=1
gpgkey=https://downloads.plex.tv/plex-keys/PlexSign.key
gpgcheck=1' | sudo tee -a /etc/yum.repos.d/plex.repo

#Install Plex Media Server
sudo yum install -y plexmediaserver

#provision rclone config
sudo cat <<EOF >> /home/ec2-user/.config/rclone/rclone.conf 
[plexmini]
type = drive
client_id = 139431920057-xxxxxxxxx.apps.googleusercontent.com
client_secret = xxxxxxxxx
scope = drive.readonly
root_folder_id = xxxxxxxxx
token = {"access_token":"ya29.xxxxxxxxx","token_type":"Bearer","refresh_token":"1//0dPaUQ56iNL_KCgYIARAAGA0SNwF-L9IrxApvn7ZGtkuhS1SiKMnQUlNzeuOifPwseKIkHkDNR_QtK259yponPaMT3hGLhyRBIPQ","expiry":"2021-06-28T21:17:21.475886296Z"}
EOF

#provision rclone startup service using systemd
cat <<EOF >> /etc/systemd/system/rclone.service
[Unit]
Description=RClone Service
After=network-online.target

[Service]
Type=notify
KillMode=none
RestartSec=5
ExecStart=/usr/bin/rclone mount plexmini: /home/ec2-user/plexmedia \
--allow-other \
--allow-non-empty \
--dir-cache-time 1000h \
--log-file=/home/ec2-user/rclonelog.log \
--log-level INFO
ExecStop=/bin/fusermount -uz /home/ec2-user/plexmedia
Restart=on-failure
User=ec2-user
Group=ec2-user

[Install]
WantedBy=multi-user.target
EOF

#Start plex server and enable it on boot
sudo systemctl start plexmediaserver.service
sudo systemctl enable plexmediaserver.service

#Start rclone service and enable it on boot
sudo systemctl start plexmediaserver.service
sudo systemctl enable plexmediaserver.service

#Add ec2-user to plex group and vice versa.
sudo usermod -a -G ec2-user plex
sudo usermod -a -G plex ec2-user

#chmod your media folder(s). I made a single plexmedia folder for everything. Yours can/will be different
sudo chmod 755 /home/ec2-user/plexmedia








