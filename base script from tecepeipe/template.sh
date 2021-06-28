#cloud-config
ssh_deletekeys: false
ssh_authorized_keys:
- ssh-rsa xxxxxx imported-openssh-key
cloud_final_modules:
- [ssh, always]

#!/bin/bash
amazon-linux-extras install epel
yum update -y
yum install -y fuse telnet nload curl ntp

ntpdate time.windows.com

# Downloading, installing, configuring rclone

curl https://rclone.org/install.sh | sudo bash
cat <<EOF >> $(rclone config file | tail -n 1)
[onedrive]
type = onedrive
client_id = xxxxxxxxx
client_secret = xxxxxxx
token = {"access_token":"xxxxxxxxxx"}
EOF

cat <<EOF >> /etc/rc.local
rclone mount onedrive:Filmez /data/media/movies/ --read-only --uid 1000 --gid 1000 --allow-other --daemon
rclone mount onedrive:"TV Series" /data/media/tv/ --read-only --uid 1000 --gid 1000 --allow-other --daemon
EOF

# Creating plex+tautulli container

usermod -a -G docker ec2-user
mkdir -p /data/plex ; mkdir -p /data/media/tv ; mkdir -p /data/media/movies
chown -R ec2-user:ec2-user /data/media/ ; chown -R ec2-user:ec2-user /data/plex/
mkdir /data/tautulli ; chown ec2-user:ec2-user /data/tautulli
systemctl enable docker ; service docker start

docker create \
--name=plex --net=host -e VERSION=latest \
-e PUID=$(id -u ec2-user) -e PGID=$(id -g ec2-user) \
-v /data/plex:/config -v /data/media/tv:/data/tvshows -v /data/media/movies:/data/movies \
--restart unless-stopped linuxserver/plex
docker start plex

docker create \
--name=tautulli \
-e PUID=$(id -u ec2-user) -e PGID=$(id -g ec2-user) \
-p 8181:8181 \
-v /data/tautulli:/config \
-v /data/plex/Library/Application\ Support/Plex\ Media\ Server/Logs:/logs \
--restart unless-stopped linuxserver/tautulli
docker start tautulli