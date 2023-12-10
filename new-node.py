import csv
import os
import shutil
import sys

PATH = "/opt"



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
        # 添加镜像
        shell = '''
            apt install git && git clone https://github.com/fastflyk/node.git %s
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
        os.system('systemctl stop %s.service && rm /etc/systemd/system/%s.service -f' % model)
        shutil.rmtree(model_path)
    shutil.copytree(node_path, model_path)
    ishell_tpl = '''
        cd %s
        cat > '%s.service' << EOF
        [Unit]
        Description=%s Service
        After=network.target nss-lookup.target
        Wants=network.target

        [Service]
        User=root
        Group=root
        Type=simple
        LimitAS=infinity
        LimitRSS=infinity
        LimitCORE=infinity
        LimitNOFILE=999999
        WorkingDirectory=/opt/%s
        ExecStart=/opt/%s --config /opt/%s/config/config.yml
        Restart=on-failure
        RestartSec=10

        [Install]
        WantedBy=multi-user.target
        EOF

        sed -i 's/\/etc\/XrayR/\/opt\/%s\/config' ./config/config.yml
        mv ./XrayR ./%s
        systemctl daemon-reload
        systemctl stop %s
        systemctl enable %s
        systemctl start %s
    '''
    ishell = ishell_tpl % (model_path, model, model, model, model, model, model, model, model, model, model)
    os.system(ishell)



    # 添加依赖
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
