import csv
import os
import shutil
import sys

PATH = "/opt"

# 初始化
def init():
    os.system('apt update && apt install -y rsync vim nload htop iperf3 ca-certificates curl')

def yh():
    yh = '''
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
    '''
    with open('/etc/sysctl.conf', 'w+') as f:
        f.write(yh)


def install_docker():
    # 检查操作系统版本
    info = get_os()
    if info['ID'] == 'debian':
        shell = '''
        apt-get remove docker docker-engine docker.io containerd runc |
        apt-get update && apt-get install -y ca-certificates curl gnupg gpg &&
        install -m 0755 -d /etc/apt/keyrings &&
        curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg &&
        chmod a+r /etc/apt/keyrings/docker.gpg &&
        echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null  &&
        apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        '''
        os.system(shell)
    elif info['ID'] == 'ubuntu':
        shell = '''
        apt-get remove docker docker-engine docker.io containerd runc |
        apt-get update && apt-get -y install ca-certificates curl gnupg gpg &&
        install -m 0755 -d /etc/apt/keyrings &&
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg &&
        chmod a+r /etc/apt/keyrings/docker.gpg &&
        echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null  &&
        apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        '''
        os.system(shell)
    else:
        print('不支持的操作系统！')
        exit


# 添加node
# ApiHost
# ApiKey
# NodeID
# NodeType
# domain
# email
# cfApiKey
def node(model, NodeID, domain, NodeType = 'Trojan'):
    node_path = os.path.join(PATH, 'node')
    if (not os.path.exists(node_path) or os.path.isfile(node_path)):
        install_docker()
        # 添加镜像
        shell = '''
        docker pull ghcr.io/xrayr-project/xrayr:latest && apt install git && git clone https://github.com/fastflyk/node.git %s
        '''
        os.system(shell % node_path)
    # 复制文件
    print(node_path)
    print(os.path.join(PATH, model))
    model_path = os.path.join(PATH, model)
    if os.path.exists(model_path):
        shutil.rmtree(model_path)
    shutil.copytree(node_path, model_path)
    config  = os.path.join(os.path.join(node_path, 'config'), 'config.yml')
    with open(config, 'r', encoding = "utf-8") as file:
        str  = file.read()
        info = get_info(model)
        print(info)
        new_str = str.format(ApiHost = info['ApiHost'],ApiKey = info['ApiKey'],NodeID = NodeID,NodeType = NodeType,domain = domain,email = info['email'],cfApiKey = info['cfApiKey'])
        model_config  = os.path.join(os.path.join(model_path, 'config'), 'config.yml')
        with open(model_config, 'w') as mf:
            mf.write(new_str)



# PRETTY_NAME="Debian GNU/Linux 11 (bullseye)"
# NAME="Debian GNU/Linux"
# VERSION_ID="11"
# VERSION="11 (bullseye)"
# VERSION_CODENAME=bullseye
# ID=debian
# HOME_URL="https://www.debian.org/"
# SUPPORT_URL="https://www.debian.org/support"
# BUG_REPORT_URL="https://bugs.debian.org/"
def get_os():
    data = {}
    with open("/etc/os-release") as f:
        reader = csv.reader(f, delimiter="=")
        for row in reader:
            if row:
                data[row[0]] = row[1]
    return data

# 获取配置信息
def get_info(model):
    data = {}
    with open("/opt/%s.info" % model) as f:
        reader = csv.reader(f, delimiter="=")
        for row in reader:
            if row:
                data[row[0]] = row[1]
    return data


if __name__ == "__main__":
    node(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4])
