#Install amazon linux essentials
amazon-linux-extras install epel

#Install fuse
yum install -y fuse 

#Install Rclone
curl https://rclone.org/install.sh | sudo bash

#Install Plex Media Server. Yum does not have a configured repo for Plex so we need to create a configuration file for yum in /etc/yum.repos.d/ pointing to plex's repo. 
cd /etc/yum.repos.d/
sudo nano plex.repo

#Provision the plex.repo file with the following configuration information and write to disk: 
#[PlexRepo]
#name=PlexRepo
#baseurl=https://downloads.plex.tv/repo/rpm/$basearch/
#enabled=1
#gpgkey=https://downloads.plex.tv/plex-keys/PlexSign.key
#gpgcheck=1

#Install Plex Media Server
sudo yum install -y plexmediaserver

#Start plex server and enable it on boot
sudo systemctl start plexmediaserver.service
sudo systemctl enable plexmediaserver.service

#Verify plex is running (Look for active running)
sudo systemctl status plexmediaserver

#Hop on the AWS console and configure your instance security group as desired. At a minimum you'll need TCP 32400 to access the web interface publicly and 8888 to tunnel in
#using putty so you can enable remote access for the first run configuration. Google how to set up putty SSH tunnel its easy. When on the tunnel I pasted http://localhost:8080/web
#Into my firefox address bar and plex presented itself for first run configuration. If you are smart, you will save the SSH putty session within putty so you do not need to do it all by hand if you need to connect
#again. 

#IMPORTANT! Before killing the putty tunnel go to Plex remote settings and specify a manual remote access port and apply, otherwise you will require an SSH tunnel for performing administrative actions.

#Test Plex (your url will be your ec2 instance public ip)
 http://xxxxxxxx:32400/web

#Configure rclone for google drive. You will need your Google client ID and secret, and optionally a root folder within your drive and its URL ID. Rclone documentation can help you find the 
#root folder ID if you choose to specify one. 
rclone config
#new remote
#Name it (Mine was plexmini)
#15 for gdrive
#Insert your unique client ID
#Insert your unique secret
#Choose option 2 for read only access.
#Insert root folder ID if desired otherwise leave default.
#Leave service account blank unless using a service account (see Rclone documentation)
#No for advanced config
#No to auto config because we are using AWS and are headless
#Control + Click to follow auth link or copy paste into browser and authorize. Firefox tried to block the insecure page but choose advanced > proceed anyway. 
#If you have not already you may need to take your google API out of testing so that you are able to complete this step. See Rclone drive documentation. If you do not do this you will receive
#A google developer error telling you to ask yourself for API permission. 
#copy the auth code back to Rclone. 
#No to team drive unless using a team drive.
#Double check your entered information and yes this is okay. 
#Q to quit configuration and go back to terminal. 

#Verify Rclone can see your drive
rclone lsd REPLACEWITHYOURREMOTENAME:

#chmod your media folders (these are my folders that I made in my ec2-user directory, yours will be different)
sudo chown -R ec2-user:ec2-user plexmedia
sudo chown -R ec2-user:ec2-user plexmedia/tv
sudo chown -R ec2-user:ec2-user plexmedia/movies

#We need to mount google drive in Rclone and associate it with the local folders we created earlier. I chose to mount tv and movies separately. 
rclone mount --daemon REPLACEWITHYOURREMOTENAME: /REPLACEWITHYOURMEDIAFOLDERS/









