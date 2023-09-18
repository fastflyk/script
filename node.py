import csv
import os
import shutil
import sys

PATH = "/opt"

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
def node(model, NodeID, domain, NodeType = 'Trojan', certMode = 'dns'):
    node_path = os.path.join(PATH, 'node')
    if (not os.path.exists(node_path) or os.path.isfile(node_path)):
        install_docker()
        # 添加镜像
        shell = '''
        docker pull ghcr.io/xrayr-project/xrayr:latest && apt install git && git clone https://github.com/fastflyk/node.git %s
        '''
        os.system(shell % node_path)
    else:
        shell = '''
            cd %s && git pull origin main
        '''
        os.system(shell % node_path)
    # 复制文件
    print(node_path)
    print(os.path.join(PATH, model))
    model_path = os.path.join(PATH, model)
    if os.path.exists(model_path):
        os.system('cd %s && docker compose down' % model_path)
        shutil.rmtree(model_path)
    shutil.copytree(node_path, model_path)
    config  = os.path.join(os.path.join(node_path, 'config'), 'config.yml')
    with open(config, 'r', encoding = "utf-8") as file:
        str  = file.read()
        info = get_info(model)
        print(info)
        new_str = str.format(ApiHost = info['ApiHost'],ApiKey = info['ApiKey'],NodeID = NodeID,NodeType = NodeType,domain = domain,email = info['email'],cfApiKey = info['cfApiKey'], certMode = certMode)
        model_config  = os.path.join(os.path.join(model_path, 'config'), 'config.yml')
        with open(model_config, 'w') as mf:
            mf.write(new_str)
            os.system('cd %s && docker compose up -d' % model_path)



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
    node(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5])
