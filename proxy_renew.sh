#!/bin/bash

WorkDir="/opt/mtproxy/"

filev4=${WorkDir}proxy-multi.conf
filev6=${WorkDir}proxy-multi6.conf
curl -s https://core.telegram.org/getProxyConfigV6 -o $filev6 
curl -s https://core.telegram.org/getProxyConfig -o $filev4

fileout=${WorkDir}proxy-multi-all.conf

#head -n2 $filev4 > $fileout
grep -v "proxy_for" $filev4 > $fileout
for i in {1..5} 
do
	grep "proxy_for $i" $filev6 >> $fileout
	grep "proxy_for $i" $filev4 >> $fileout
	grep "proxy_for -$i" $filev6 >> $fileout
	grep "proxy_for -$i" $filev4 >> $fileout
done

systemctl reload mtproxy.service
