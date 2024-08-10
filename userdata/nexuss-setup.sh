#!/bin/bash

# Install Java 1.8 and wget
yum install java-1.8.0-openjdk.x86_64 wget -y

# Create necessary directories
mkdir -p /opt/nexus/
mkdir -p /tmp/nexus/
cd /tmp/nexus/

# Download the latest Nexus version
NEXUSURL="https://download.sonatype.com/nexus/3/latest-unix.tar.gz"
wget $NEXUSURL -O nexus.tar.gz

# Extract the Nexus tarball
EXTOUT=$(tar xzvf nexus.tar.gz)
NEXUSDIR=$(echo $EXTOUT | head -n 1 | cut -d '/' -f1)

# Remove the tarball to clean up
rm -rf /tmp/nexus/nexus.tar.gz

# Copy the extracted files to /opt/nexus
cp -r /tmp/nexus/* /opt/nexus/

# Create a user for Nexus
useradd nexus

# Change ownership of the Nexus directory
chown -R nexus:nexus /opt/nexus

# Create a systemd service file for Nexus
cat <<EOT > /etc/systemd/system/nexus.service
[Unit]
Description=Nexus Service
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

# Configure Nexus to run as the nexus user
echo 'run_as_user="nexus"' > /opt/nexus/$NEXUSDIR/bin/nexus.rc

# Reload systemd to pick up the new nexus.service file
systemctl daemon-reload

# Start and enable the Nexus service
systemctl start nexus
systemctl enable nexus
