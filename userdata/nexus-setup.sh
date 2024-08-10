#!/bin/bash

# Install Java 17 (required by Nexus 3.x)

yum install java-17-openjdk.x86_64 wget -y



# Create necessary directories

mkdir -p /opt/nexus/

mkdir -p /tmp/nexus/

cd /tmp/nexus/



# Download Nexus

NEXUSURL="https://download.sonatype.com/nexus/3/latest-unix.tar.gz"

wget $NEXUSURL -O nexus.tar.gz



# Extract Nexus and get the directory name

EXTOUT=$(tar xzvf nexus.tar.gz)

NEXUSDIR=$(echo $EXTOUT | cut -d '/' -f1)



# Clean up the tar file and copy Nexus to /opt

rm -rf /tmp/nexus/nexus.tar.gz

cp -r /tmp/nexus/* /opt/nexus/



# Create the nexus user and set ownership

useradd nexus

chown -R nexus:nexus /opt/nexus



# Create the systemd service file

cat <<EOT>> /etc/systemd/system/nexus.service

[Unit]

Description=Nexus service

After=network.target



[Service]

Type=forking

LimitNOFILE=65536

ExecStart=/opt/nexus/$NEXUSDIR/bin/nexus start

ExecStop=/opt/nexus/$NEXUSDIR/bin/nexus stop

User=nexus

Restart=on-abort



[Install]

WantedBy=multi-user.target

EOT



# Set Nexus to run as the nexus user

echo 'run_as_user="nexus"' > /opt/nexus/$NEXUSDIR/bin/nexus.rc



# Ensure the Nexus scripts are executable

chmod +x /opt/nexus/$NEXUSDIR/bin/nexus



# Reload systemd and start Nexus

systemctl daemon-reload

systemctl start nexus

systemctl enable nexus