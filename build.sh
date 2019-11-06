#!/bin/bash

## Install dependencies
apt update
apt install -y curl build-essential libssl-dev zlib1g-dev

## Compile mtproto-proxy
make

## Create working directory
WorkDir="/opt/mtproxy/"
mkdir $WorkDir
cp objs/bin/mtproto-proxy $WorkDir

## Create systemd service description
echo "[Unit]
Description=MTProxy
After=network.target

[Service]
Type=simple
WorkingDirectory=${WorkDir}
ExecStart=${WorkDir}mtproto-proxy --ipv6 -u nobody -p 8888 -H 443,8443,8080 -R -M 2 --aes-pwd proxy-secret proxy-multi-all.conf
Restart=on-failure
ExecReload=/bin/kill -s HUP \$MAINPID

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/mtproxy.service

## Get telegram configuration
cp proxy_renew.sh $WorkDir
cd $WorkDir
chmod u+x proxy_renew.sh
/bin/bash proxy_renew.sh

## Create cron job to renew configuration daily
crontab -l | { cat; echo "# Renew MTProxy configuration daily at 1 UTC
0 1 * * * ${WorkDir}proxy_renew.sh"; } | crontab -

## Obtain a secret
curl -s https://core.telegram.org/getProxySecret -o proxy-secret

## Modify proxy options to satisfy your needs
## Add your secret and tag 
echo "Modify options"
vim /etc/systemd/system/mtproxy.service

## Run the service
systemctl daemon-reload
systemctl start mtproxy.service
systemctl enable mtproxy.service
