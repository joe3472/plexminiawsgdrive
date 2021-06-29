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
rclone mount drive:movies /plexmedia/movies/ --read-only --uid 1000 --gid 1000 --allow-other --daemon
rclone mount drive:"TV Series" /plexmedia/tv/ --read-only --uid 1000 --gid 1000 --allow-other --daemon
EOF

# Creating plex+tautulli container

usermod -a -G docker ec2-user
mkdir -p /plexmedia ; mkdir -p /plexmedia/tv/ ; mkdir -p /plexmedia/movies/
chown -R ec2-user:ec2-user /plexmedia/ ; chown -R ec2-user:ec2-user /plexmedia/
mkdir /data/tautulli ; chown ec2-user:ec2-user /plexmedia/tautulli
systemctl enable docker ; service docker start

docker create \
--name=plex3 --net=host -e VERSION=latest \
-e PUID=$(id -u ec2-user) -e PGID=$(id -g ec2-user) \
-v /home/ec2-user/plexmedia/plex:/config -v /home/ec2-user/plexmedia/tv -v /home/ec2-user/plexmedia/movies \
--restart unless-stopped linuxserver/plex
docker start plex

docker create \
--name=tautulli \
-e PUID=$(id -u ec2-user) -e PGID=$(id -g ec2-user) \
-p 8181:8181 \
-v /plexmedia/tautulli:/config \
-v /data/plex/Library/Application\ Support/Plex\ Media\ Server/Logs:/logs \
--restart unless-stopped linuxserver/tautulli
docker start tautulli