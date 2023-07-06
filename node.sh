#!/usr/bin/env bash

check_sys() {
  if [[ -f /etc/redhat-release ]]; then
    release="centos"
  elif cat /etc/issue | grep -q -E -i "debian"; then
    release="debian"
  elif cat /etc/issue | grep -q -E -i "ubuntu"; then
    release="ubuntu"
  elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
    release="centos"
  elif cat /proc/version | grep -q -E -i "debian"; then
    release="debian"
  elif cat /proc/version | grep -q -E -i "ubuntu"; then
    release="ubuntu"
  elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
    release="centos"
  fi
}

check_sys &&

apt update &&
apt install -y rsync vim nload htop iperf3 &&
cat > '/etc/sysctl.conf' << EOF
fs.file-max=1000000
fs.inotify.max_user_instances=65536

net.ipv4.conf.all.route_localnet=1
net.ipv4.ip_forward=1
net.ipv4.conf.all.forwarding=1
net.ipv4.conf.default.forwarding=1
net.ipv4.ip_local_port_range = 10000 65535
net.ipv6.conf.all.forwarding = 1
net.ipv6.conf.default.forwarding = 1
net.ipv6.conf.lo.forwarding = 1
net.ipv6.conf.all.disable_ipv6 = 0
net.ipv6.conf.default.disable_ipv6 = 0
net.ipv6.conf.lo.disable_ipv6 = 0
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_syncookies=1
net.ipv4.tcp_retries1=3
net.ipv4.tcp_retries2=5
net.ipv4.tcp_orphan_retries=3
net.ipv4.tcp_syn_retries=3
net.ipv4.tcp_synack_retries=3
net.ipv4.tcp_tw_reuse=1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_fin_timeout=10
net.ipv4.tcp_max_tw_buckets=2000000
net.ipv4.tcp_max_syn_backlog=131072
net.core.netdev_max_backlog=131072
net.core.somaxconn=32768
net.ipv4.tcp_keepalive_time=60
net.ipv4.tcp_keepalive_probes=6
net.ipv4.tcp_keepalive_intvl=10
net.ipv4.tcp_fastopen=3
net.ipv4.tcp_autocorking=0
net.ipv4.tcp_slow_start_after_idle=0
net.ipv4.tcp_no_metrics_save=1
net.ipv4.tcp_ecn=0
net.ipv4.tcp_frto=0
net.ipv4.tcp_mtu_probing=0
net.ipv4.tcp_rfc1337=1
net.ipv4.tcp_sack=1
net.ipv4.tcp_fack=1
net.ipv4.tcp_window_scaling=1
net.ipv4.tcp_adv_win_scale=-2
net.ipv4.tcp_moderate_rcvbuf=1
net.core.rmem_max=335544320
net.core.wmem_max=335544320
net.core.optmem_max = 65536
net.ipv4.tcp_rmem=8192 262144 536870912
net.ipv4.tcp_wmem=4096 16384 536870912
net.ipv4.tcp_collapse_max_bytes = 6291456
net.ipv4.tcp_notsent_lowat = 131072
net.ipv4.udp_rmem_min=8192
net.ipv4.udp_wmem_min=8192
net.ipv4.tcp_mem=262144 1048576 4194304
net.ipv4.udp_mem=262144 1048576 4194304
net.ipv4.tcp_congestion_control=bbr
net.core.default_qdisc=fq_pie
net.ipv4.ping_group_range=0 2147483647
EOF
sysctl -p &&

if [[ "${release}" == "debian" ]]; then
    apt-get remove docker docker-engine docker.io containerd runc |
    apt-get update &&
    apt-get install -y ca-certificates curl gnupg gpg &&
    install -m 0755 -d /etc/apt/keyrings &&
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg &&
    chmod a+r /etc/apt/keyrings/docker.gpg &&
    echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null  &&
    apt-get update &&
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin &&
elif [[ "${release}" == "ubuntu" ]]; then
    apt-get remove docker docker-engine docker.io containerd runc |
    apt-get update &&
    apt-get -y install ca-certificates curl gnupg gpg &&
    install -m 0755 -d /etc/apt/keyrings &&
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg &&
    chmod a+r /etc/apt/keyrings/docker.gpg &&
    echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null  &&
    apt-get update &&
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin &&
fi

docker pull ghcr.io/xrayr-project/xrayr:latest &&
apt install git &&
git clone https://github.com/XrayR-project/XrayR-release ./jcbb &&
cp -r $HOME/jcbb $HOME/fly &&
cat > $HOME/jcbb/config/config << EOF
Log:
  Level: none # Log level: none, error, warning, info, debug
  AccessPath: # /etc/XrayR/access.Log
  ErrorPath: # /etc/XrayR/error.log
DnsConfigPath: # /etc/XrayR/dns.json # Path to dns config, check https://xtls.github.io/config/dns.html for help
RouteConfigPath: # /etc/XrayR/route.json # Path to route config, check https://xtls.github.io/config/routing.html for help
InboundConfigPath: # /etc/XrayR/custom_inbound.json # Path to custom inbound config, check https://xtls.github.io/config/inbound.html for help
OutboundConfigPath: # /etc/XrayR/custom_outbound.json # Path to custom outbound config, check https://xtls.github.io/config/outbound.html for help
ConnectionConfig:
  Handshake: 4 # Handshake time limit, Second
  ConnIdle: 30 # Connection idle time limit, Second
  UplinkOnly: 2 # Time limit when the connection downstream is closed, Second
  DownlinkOnly: 4 # Time limit when the connection is closed after the uplink is closed, Second
  BufferSize: 64 # The internal cache size of each connection, kB
Nodes:
  -
    PanelType: "NewV2board" # Panel type: SSpanel, V2board, NewV2board, PMpanel, Proxypanel, V2RaySocks
    ApiConfig:
      ApiHost: "https://www.ckcloud.shop/"
      ApiKey: "jcbb12344321QWEASDzxc"
      NodeID: $2
      NodeType: Trojan # Node type: V2ray, Shadowsocks, Trojan, Shadowsocks-Plugin
      Timeout: 30 # Timeout for the api request
      EnableVless: false # Enable Vless for V2ray Type
      EnableXTLS: false # Enable XTLS for V2ray and Trojan
      SpeedLimit: 0 # Mbps, Local settings will replace remote settings, 0 means disable
      DeviceLimit: 0 # Local settings will replace remote settings, 0 means disable
      RuleListPath: /etc/XrayR/rulelist # Path to local rulelist file
    ControllerConfig:
      ListenIP: 0.0.0.0 # IP address you want to listen
      SendIP: 0.0.0.0 # IP address you want to send pacakage
      UpdatePeriodic: 60 # Time to update the nodeinfo, how many sec.
      EnableDNS: true # Use custom DNS config, Please ensure that you set the dns.json well
      DNSType: UseIP # AsIs, UseIP, UseIPv4, UseIPv6, DNS strategy
      EnableProxyProtocol: false # Only works for WebSocket and TCP
      AutoSpeedLimitConfig:
        Limit: 0 # Warned speed. Set to 0 to disable AutoSpeedLimit (mbps)
        WarnTimes: 0 # After (WarnTimes) consecutive warnings, the user will be limited. Set to 0 to punish overspeed user immediately.
        LimitSpeed: 0 # The speedlimit of a limited user (unit: mbps)
        LimitDuration: 0 # How many minutes will the limiting last (unit: minute)
      GlobalDeviceLimitConfig:
        Enable: false # Enable the global device limit of a user
        RedisAddr: 127.0.0.1:6379 # The redis server address
        RedisPassword: YOUR PASSWORD # Redis password
        RedisDB: 0 # Redis DB
        Timeout: 5 # Timeout for redis request
        Expiry: 60 # Expiry time (second)
      EnableFallback: false # Only support for Trojan and Vless
      FallBackConfigs:  # Support multiple fallbacks
        -
          SNI: # TLS SNI(Server Name Indication), Empty for any
          Alpn: # Alpn, Empty for any
          Path: # HTTP PATH, Empty for any
          Dest: 80 # Required, Destination of fallback, check https://xtls.github.io/config/features/fallback.html for details.
          ProxyProtocolVer: 0 # Send PROXY protocol version, 0 for dsable
      CertConfig:
        CertMode: dns # Option about how to get certificate: none, file, http, tls, dns. Choose "none" will forcedly disable the tls config.
        CertDomain: "$1.ckcloud.info" # Domain to cert
        CertFile: /etc/XrayR/cert/$1.ckcloud.info.cert # Provided if the CertMode is file
        KeyFile: /etc/XrayR/cert/$1.ckcloud.info.key
        Provider: cloudflare # DNS cert provider, Get the full support list here: https://go-acme.github.io/lego/dns/
        Email: jcbbnw@gmail.com
        DNSEnv: # DNS ENV option used by DNS provider
          CLOUDFLARE_EMAIL: jcbbnw@gmail.com
          CLOUDFLARE_API_KEY: 089bc2d718179076a862320688e9e572c443e
`
EOF;
cat > $HOME/fly/config/config << EOF
Log:
  Level: none # Log level: none, error, warning, info, debug
  AccessPath: # /etc/XrayR/access.Log
  ErrorPath: # /etc/XrayR/error.log
DnsConfigPath: # /etc/XrayR/dns.json # Path to dns config, check https://xtls.github.io/config/dns.html for help
RouteConfigPath: # /etc/XrayR/route.json # Path to route config, check https://xtls.github.io/config/routing.html for help
InboundConfigPath: # /etc/XrayR/custom_inbound.json # Path to custom inbound config, check https://xtls.github.io/config/inbound.html for help
OutboundConfigPath: # /etc/XrayR/custom_outbound.json # Path to custom outbound config, check https://xtls.github.io/config/outbound.html for help
ConnectionConfig:
  Handshake: 4 # Handshake time limit, Second
  ConnIdle: 30 # Connection idle time limit, Second
  UplinkOnly: 2 # Time limit when the connection downstream is closed, Second
  DownlinkOnly: 4 # Time limit when the connection is closed after the uplink is closed, Second
  BufferSize: 64 # The internal cache size of each connection, kB
Nodes:
  -
    PanelType: "NewV2board" # Panel type: SSpanel, V2board, NewV2board, PMpanel, Proxypanel, V2RaySocks
    ApiConfig:
      ApiHost: "https://www.fastestcloud.xyz"
      ApiKey: "d1525452-34a5-4763-a393-d645e2337677"
      NodeID: $2
      NodeType: Trojan # Node type: V2ray, Shadowsocks, Trojan, Shadowsocks-Plugin
      Timeout: 30 # Timeout for the api request
      EnableVless: false # Enable Vless for V2ray Type
      EnableXTLS: false # Enable XTLS for V2ray and Trojan
      SpeedLimit: 0 # Mbps, Local settings will replace remote settings, 0 means disable
      DeviceLimit: 0 # Local settings will replace remote settings, 0 means disable
      RuleListPath: /etc/XrayR/rulelist # Path to local rulelist file
    ControllerConfig:
      ListenIP: 0.0.0.0 # IP address you want to listen
      SendIP: 0.0.0.0 # IP address you want to send pacakage
      UpdatePeriodic: 60 # Time to update the nodeinfo, how many sec.
      EnableDNS: true # Use custom DNS config, Please ensure that you set the dns.json well
      DNSType: UseIP # AsIs, UseIP, UseIPv4, UseIPv6, DNS strategy
      EnableProxyProtocol: false # Only works for WebSocket and TCP
      AutoSpeedLimitConfig:
        Limit: 0 # Warned speed. Set to 0 to disable AutoSpeedLimit (mbps)
        WarnTimes: 0 # After (WarnTimes) consecutive warnings, the user will be limited. Set to 0 to punish overspeed user immediately.
        LimitSpeed: 0 # The speedlimit of a limited user (unit: mbps)
        LimitDuration: 0 # How many minutes will the limiting last (unit: minute)
      GlobalDeviceLimitConfig:
        Enable: false # Enable the global device limit of a user
        RedisAddr: 127.0.0.1:6379 # The redis server address
        RedisPassword: YOUR PASSWORD # Redis password
        RedisDB: 0 # Redis DB
        Timeout: 5 # Timeout for redis request
        Expiry: 60 # Expiry time (second)
      EnableFallback: false # Only support for Trojan and Vless
      FallBackConfigs:  # Support multiple fallbacks
        -
          SNI: # TLS SNI(Server Name Indication), Empty for any
          Alpn: # Alpn, Empty for any
          Path: # HTTP PATH, Empty for any
          Dest: 80 # Required, Destination of fallback, check https://xtls.github.io/config/features/fallback.html for details.
          ProxyProtocolVer: 0 # Send PROXY protocol version, 0 for dsable
      CertConfig:
        CertMode: dns # Option about how to get certificate: none, file, http, tls, dns. Choose "none" will forcedly disable the tls config.
        CertDomain: "$1.ckcloud.info" # Domain to cert
        CertFile: /etc/XrayR/cert/$1.ckcloud.info.cert # Provided if the CertMode is file
        KeyFile: /etc/XrayR/cert/$1.ckcloud.info.key
        Provider: cloudflare # DNS cert provider, Get the full support list here: https://go-acme.github.io/lego/dns/
        Email: jcbbnw@gmail.com
        DNSEnv: # DNS ENV option used by DNS provider
          CLOUDFLARE_EMAIL: jcbbnw@gmail.com
          CLOUDFLARE_API_KEY: 089bc2d718179076a862320688e9e572c443e
`
EOF;

cat > $HOME/fly/config/rulelist << EOF
(.+\.|^)(360|so|qihoo|360safe|qhimg|360totalsecurity|yunpan)\.(cn|com)
(api|ps|sv|offnavi|newvector|ulog|newloc).(map|imap).(baidu|n.shifen).com
(api|ps|sv|offnavi|newvector|ulog\.imap|newloc)(\.map|)\.(baidu|n\.shifen)\.com
(.*\.)(visa|mycard|mastercard|gash|beanfun|bank).*
(.*\.)(metatrader4|metatrader5|mql5)\.(org|com|net)
(Subject|HELO|SMTP)
(^.*@)(guer­ril­la­mail|guer­ril­la­mail­block|shark­lasers|grr|poke­mail|spam4|bc­cto|chacuo|027168).(info|biz|com|de|net|org|me|la)
(..)(dafahao|minghui|dongtaiwang|epochtimes|ntdtv|ßßfalundafa|wujieliulan|zhengjian).(org|com|net) (..)(dafa­hao|minghui|dong­tai­wang|epochtimes|nt­dtv|falundafa|wu­jieli­u­lan|zhengjian).(org|com|net) (.*.)(dafa­hao|minghui|dong­tai­wang|epochtimes|nt­dtv|falundafa|wu­jieli­u­lan|zhengjian).(org|com|net)
(tor­rent|.tor­rent|peer_id=|in­fo_hash|get_peers|find­_n­ode|Bit­Tor­rent|an­nounce_peer|an­nounce.php?passkey=)
(.?)(xun­lei|sandai|Thun­der|XL­LiveUD)(.)
(.+.|^)(whatismyip|whatismyi­pad­dress|ipip|iplo­ca­tion|myip|whatismy­browser).(cn|com|net|com|net­work)
(.*\.)(pincong)\.(rocks)
(.*.)(64tianwang|beijingspring|boxun|broadpressinc|chengmingmag|chenpokong|chinaaffairs|chinadigitaltimes|chinesepen|dafahao|dalailamaworld|dalianmeng|dongtaiwang|epochweekly|erabaru|fgmtv|hrichina|huanghuagang|hxwq|jiangweiping|lagranepoca|lantosfoundation|minghui|minzhuzhongguo|ned|ninecommentaries|ogate|renminbao|rfa|secretchina|shenyun|shenyunperformingarts|shenzhoufilm|soundofhope|tiantibooks|tibetpost|truthmoviegroup.wixsite|tuidang|uhrp|uyghuramerican|voachinese|vot|weijingsheng|wujieliulan|xizang-zhiye|zhengjian|zhuichaguoji).(org|com|net)
(.*\.)(gov|12377|12315|talk.news.pts|zhuichaguoji|efcc|cyberpolice|tuidang|nytimes|falundafa|falunaz|110.qq|mingjingnews|inmediahk|xinsheng|12321|epochweekly|cn.rfi|mingjing|chinaaid|botanwang|xinsheng|rfi|breakgfw|chengmingmag|jinpianwang|xizang-zhiye|breakgfw|qi-gong|voachinese|mhradio|rfa|edoors|edoors|renminbao|soundofhope|zhengjian|dafahao|minghui|dongtaiwang|epochtimes|ntdtv|falundafa|wujieliulan|aboluowang|bannedbook|secretchina|dajiyuan|boxun|chinadigitaltimes|huaglad|dwnews|creaders|oneplusnews|rfa|nextdigital|pincong|gtv|kwok7)\.(cn|com|org|net|club|net|fr|tw|hk|eu|info|me|rocks)
bannedbook.org
jw.org
tibet.net
rfa.org
citizenpowerfor
freetibet
dalailama
nextdigital
EOF;
cat > $HOME/jcbb/config/rulelist << EOF
(.+\.|^)(360|so|qihoo|360safe|qhimg|360totalsecurity|yunpan)\.(cn|com)
(api|ps|sv|offnavi|newvector|ulog|newloc).(map|imap).(baidu|n.shifen).com
(api|ps|sv|offnavi|newvector|ulog\.imap|newloc)(\.map|)\.(baidu|n\.shifen)\.com
(.*\.)(visa|mycard|mastercard|gash|beanfun|bank).*
(.*\.)(metatrader4|metatrader5|mql5)\.(org|com|net)
(Subject|HELO|SMTP)
(^.*@)(guer­ril­la­mail|guer­ril­la­mail­block|shark­lasers|grr|poke­mail|spam4|bc­cto|chacuo|027168).(info|biz|com|de|net|org|me|la)
(..)(dafahao|minghui|dongtaiwang|epochtimes|ntdtv|ßßfalundafa|wujieliulan|zhengjian).(org|com|net) (..)(dafa­hao|minghui|dong­tai­wang|epochtimes|nt­dtv|falundafa|wu­jieli­u­lan|zhengjian).(org|com|net) (.*.)(dafa­hao|minghui|dong­tai­wang|epochtimes|nt­dtv|falundafa|wu­jieli­u­lan|zhengjian).(org|com|net)
(tor­rent|.tor­rent|peer_id=|in­fo_hash|get_peers|find­_n­ode|Bit­Tor­rent|an­nounce_peer|an­nounce.php?passkey=)
(.?)(xun­lei|sandai|Thun­der|XL­LiveUD)(.)
(.+.|^)(whatismyip|whatismyi­pad­dress|ipip|iplo­ca­tion|myip|whatismy­browser).(cn|com|net|com|net­work)
(.*\.)(pincong)\.(rocks)
(.*.)(64tianwang|beijingspring|boxun|broadpressinc|chengmingmag|chenpokong|chinaaffairs|chinadigitaltimes|chinesepen|dafahao|dalailamaworld|dalianmeng|dongtaiwang|epochweekly|erabaru|fgmtv|hrichina|huanghuagang|hxwq|jiangweiping|lagranepoca|lantosfoundation|minghui|minzhuzhongguo|ned|ninecommentaries|ogate|renminbao|rfa|secretchina|shenyun|shenyunperformingarts|shenzhoufilm|soundofhope|tiantibooks|tibetpost|truthmoviegroup.wixsite|tuidang|uhrp|uyghuramerican|voachinese|vot|weijingsheng|wujieliulan|xizang-zhiye|zhengjian|zhuichaguoji).(org|com|net)
(.*\.)(gov|12377|12315|talk.news.pts|zhuichaguoji|efcc|cyberpolice|tuidang|nytimes|falundafa|falunaz|110.qq|mingjingnews|inmediahk|xinsheng|12321|epochweekly|cn.rfi|mingjing|chinaaid|botanwang|xinsheng|rfi|breakgfw|chengmingmag|jinpianwang|xizang-zhiye|breakgfw|qi-gong|voachinese|mhradio|rfa|edoors|edoors|renminbao|soundofhope|zhengjian|dafahao|minghui|dongtaiwang|epochtimes|ntdtv|falundafa|wujieliulan|aboluowang|bannedbook|secretchina|dajiyuan|boxun|chinadigitaltimes|huaglad|dwnews|creaders|oneplusnews|rfa|nextdigital|pincong|gtv|kwok7)\.(cn|com|org|net|club|net|fr|tw|hk|eu|info|me|rocks)
bannedbook.org
jw.org
tibet.net
rfa.org
citizenpowerfor
freetibet
dalailama
nextdigital
EOF;
cd $HOME/fly &&
docker compose down &&
docker compose up -d &&
cd $HOME/jcbb &&
docker compose down &&
docker compose up -d &&
cd ~
