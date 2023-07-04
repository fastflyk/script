#!/usr/bin/env bash

cat > "/root/$1/config/dns.json" << EOF
{
  "servers": [
    "1.1.1.1",
    "8.8.8.8",
    {
      "address": "$2",
      "port": 53,
      "domains": ["geosite:netflix","geosite:bahamut","geosite:hulu","geosite:hbo","geosite:disney","geosite:bbc","geosite:4chan","geosite:fox","geosite:abema","geosite:dmm","geosite:niconico""geosite:viu"]
    }
  ],
  "tag": "dns_inbound"
}
EOF
sed -i 's/DnsConfigPath:/DnsConfigPath: \/etc\/XrayR\/dns.json #/g' /root/$1/config/config.yml  cd ~/$1 && docker compose down && docker compose up -d  && cd ~
