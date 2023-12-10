
import json
import os
import sys


PATH = "/opt"

O_CONFIG = "config/custom_outbound.json"

R_CONFIG = "config/route.json"

D_CONFIG = "config/dns.json"


DEFAULT_DNS = '''
{
    "servers": [
        "1.1.1.1",
        "8.8.8.8",
        "localhost"
    ],
    "tag": "dns_inbound"
}
'''

DEFAULT_ROUTER = '''
{
  "domainStrategy": "IPOnDemand",
  "rules": [
    {
      "type": "field",
      "outboundTag": "block",
      "ip": [
        "geoip:private"
      ]
    },
    {
      "type": "field",
      "outboundTag": "block",
      "domain": [
        "regexp:(api|ps|sv|offnavi|newvector|ulog.imap|newloc)(.map|).(baidu|n.shifen).com",
        "regexp:(.+.|^)(360|so).(cn|com)",
        "regexp:(Subject|HELO|SMTP)",
        "regexp:(torrent|.torrent|peer_id=|info_hash|get_peers|find_node|BitTorrent|announce_peer|announce.php?passkey=)",
        "regexp:(^.@)(guerrillamail|guerrillamailblock|sharklasers|grr|pokemail|spam4|bccto|chacuo|027168).(info|biz|com|de|net|org|me|la)",
        "regexp:(.?)(xunlei|sandai|Thunder|XLLiveUD)(.)",
        "regexp:(..||)(dafahao|mingjinglive|botanwang|minghui|dongtaiwang|falunaz|epochtimes|ntdtv|falundafa|falungong|wujieliulan|zhengjian).(org|com|net)",
        "regexp:(ed2k|.torrent|peer_id=|announce|info_hash|get_peers|find_node|BitTorrent|announce_peer|announce.php?passkey=|magnet:|xunlei|sandai|Thunder|XLLiveUD|bt_key)",
        "regexp:(.*.||)(guanjia.qq.com|qqpcmgr|QQPCMGR)",
        "regexp:(.*.||)(rising|kingsoft|duba|xindubawukong|jinshanduba).(com|net|org)",
        "regexp:(.*.||)(netvigator|torproject).(com|cn|net|org)",
        "regexp:(..||)(visa|mycard|mastercard|gov|gash|beanfun|bank).",
        "regexp:(.*.||)(gov|12377|12315|talk.news.pts.org|creaders|zhuichaguoji|efcc.org|cyberpolice|aboluowang|tuidang|epochtimes|nytimes|zhengjian|110.qq|mingjingnews|inmediahk|xinsheng|breakgfw|chengmingmag|jinpianwang|qi-gong|mhradio|edoors|renminbao|soundofhope|xizang-zhiye|bannedbook|ntdtv|12321|secretchina|dajiyuan|boxun|chinadigitaltimes|dwnews|huaglad|oneplusnews|epochweekly|cn.rfi).(cn|com|org|net|club|net|fr|tw|hk|eu|info|me)",
        "regexp:(.*.||)(miaozhen|cnzz|talkingdata|umeng).(cn|com)",
        "regexp:(.*.||)(mycard).(com|tw)",
        "regexp:(.*.||)(gash).(com|tw)",
        "regexp:(.bank.)",
        "regexp:(.*.||)(pincong).(rocks)",
        "regexp:(.*.||)(taobao).(com)"
      ]
    },
    {
      "type": "field",
      "outboundTag": "block",
      "ip": [
          "127.0.0.1/32",
          "10.0.0.0/8",
          "fc00::/7",
          "fe80::/10",
          "172.16.0.0/12"
      ]
    },
    {
      "type": "field",
      "outboundTag": "block",
      "protocol": ["bittorrent"]
    },
    {
      "type": "field",
      "outboundTag": "block",
      "port": "22,23,24,25,107,194,445,465,587,992,3389,6665-6669,6679,6697,6881-6999,7000"
    }
  ]
}
'''


DEFAULT_OUT = '''
[
  {
    "tag": "IPv4_out",
    "protocol": "freedom",
    "settings": {}
  },
  {
    "tag": "IPv6_out",
    "protocol": "freedom",
    "settings": {
      "domainStrategy": "UseIPv6"
    }
  },
  {
    "protocol": "blackhole",
    "tag": "block"
  }
]
'''

DOMAIN = '''
"geosite:netflix","geosite:bahamut","geosite:hulu","geosite:hbo","geosite:disney","geosite:bbc","geosite:4chan","geosite:fox","geosite:abema","geosite:dmm","geosite:niconico","geosite:viu"
'''

GPT_DOMAIN = '''
"geosite:openai","domain:ai.com"
'''


def render(model, dns, router, out):
    model_path = os.path.join(PATH, model)
    # DNS
    with open(os.path.join(model_path, D_CONFIG), 'w+', encoding='utf-8') as f:
        f.write(dns)
    # ROUTE
    with open(os.path.join(model_path, R_CONFIG), 'w+', encoding='utf-8') as f:
        f.write(router)
    # OUT
    with open(os.path.join(model_path, O_CONFIG), 'w+') as f:
        f.write(out)

    os.system('systemctl restart %s ' % model)


def clear(model):
    render(model, DEFAULT_DNS, DEFAULT_ROUTER, DEFAULT_OUT)


def dns(model, ip):
    tpl = '''
    {
      "address": "%s",
      "port": 53,
      "domains": [%s]
    },
    ''' % ip, DOMAIN
    dns = json.loads(DEFAULT_DNS)
    dns['servers'].append(json.loads(tpl))

    render(model, tpl, DEFAULT_ROUTER, DEFAULT_OUT)


def router(model, ip, port, user, password, type):
    domain = DOMAIN
    if type == 'gpt':
        domain = GPT_DOMAIN

    router_tpl = '''
    {
      "type": "field",
      "outboundTag": "%s",
      "domain": [
        %s
      ]
    }
    '''
    out_tpl ='''
    {
        "tag": "%s",
        "protocol": "socks",
        "settings": {
            "servers": [
                {
                    "address": "%s",
                    "port": %s,
                    "users": [
                        {
                            "user": "%s",
                            "pass": "%s"
                        }
                    ]
                }
            ]
        }
    }
    '''

    model_path = os.path.join(PATH, model)
    router_str = DEFAULT_ROUTER
    # ROUTE
    with open(os.path.join(model_path, R_CONFIG), 'r', encoding='utf-8') as f:
        router_str = f.read()
    # OUT
    out_str = DEFAULT_OUT
    with open(os.path.join(model_path, O_CONFIG), 'r') as f:
        out_str = f.read()

    router =  json.loads(router_str)
    router['rules'].append(json.loads(router_tpl % (type, domain)))

    out = json.loads(out_str)
    out.append(json.loads(out_tpl % (type, ip, port, user, password)))

    render(model, DEFAULT_DNS, json.dumps(router), json.dumps(out))



if __name__ == "__main__":
    router(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5], sys.argv[6])
