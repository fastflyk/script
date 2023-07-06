#!/usr/bin/env bash

cat > "./config/dns.json" << EOF
{
  "servers": [
    "1.1.1.1",
    "8.8.8.8",
    {
      "address": "$1",
      "port": 53,
      "domains": ["geosite:netflix","geosite:bahamut","geosite:hulu","geosite:hbo","geosite:disney","geosite:bbc","geosite:4chan","geosite:fox","geosite:abema","geosite:dmm","geosite:niconico","geosite:viu"]
    }
  ],
  "tag": "dns_inbound"
}
EOF
sed -i '/DnsConfigPath:/cDnsConfigPath: \/etc\/XrayR\/dns.json' ./config/config.yml  && docker compose down && docker compose up -d  && cd ~
