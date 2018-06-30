#!/bin/bash

# while [1]
# do
#     menu
#     case $option in
#     0)
#         break;;
#     1)
#         install_webvirtmgr;;
#     2)
#         set_ssh_for_kvmserver;;
#     3) 
#         set_ssh_for_webvirtmgr;;
# done




# function menu{}
#     clear
#     echo -e "\t\t\t======Webvirtmgr setup v1.0b======"
#     echo -e "\t1. Install Webvirtmgr."
#     echo -e "\t2. Setup SSH for Webvirtmgr"
#     echo -e "\t3. Setup SSH for KVM Server"
#     echo -en "\t\tEnter option:"
#     read -n 1 option
# }


function install_webvirtmgr {
    
    #升级&更新内核
    yum -y install epel-release
    yum -y update
    yum -y install sshpass 
    rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
    rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
    yum -y --enablerepo=elrepo-kernel install kernel-ml.x86_64
    grub2-set-default 0

    #安装python及相关软件
    yum -y install git python-pip libvirt-python libxml2-python python-websockify supervisor nginx  cifs-utils 
    yum -y install gcc python-devel
    yum -y install sqlite-devel
    pip install --upgrade pip
    pip install numpy

    #安装webvirtmgr相关软件
    cd ~
    git clone git://github.com/retspen/webvirtmgr.git
    cd webvirtmgr
    pip install -r requirements.txt # or python-pip (RedHat, Fedora, CentOS, OpenSuse)
    ./manage.py syncdb
    ./manage.py collectstatic

    #You just installed Django's auth system, which means you don't have any superusers defined.
    #Would you like to create one now? (yes/no): yes (Put: yes)
    #Username (Leave blank to use 'admin'): admin (Put: your username or login)
    #E-mail address: username@domain.local (Put: your email)
    #Password: xxxxxx (Put: your password)
    #Password (again): xxxxxx (Put: confirm password)
    #Superuser created successfully.
    #添加其它管理员帐户使用 ./manage.py createsuperuser

    #设置 nginx


    #测试
    # ./manage.py runserver 0:8000


    cd ~
    mkdir /var/www
    mv webvirtmgr /var/www

    # 复制nginx.conf 到 /etc/nginx/目录（原文件覆盖）
    cp  -f ./nginx.conf   /etc/nginx/nginx.conf
    # 复制webvirtmgr.conf 到 /etc/nginx/conf.d
    cp  -f ./webvirtmgr.conf /etc/nginx/conf.d/

    chown -R nginx:nginx /var/www/webvirtmgr
    # 官方安装教程中的 webvirtmgr.conf 配置, 有些问题，有些后缀文件也需要设置代理访问，所以添加一个节
    # location ~ .*\.(js|css|ttf)$ {
    #  proxy_pass http://127.0.0.1:8000;
    # }
    # 这样.js .css .ttf 文件就可以代理访问，不会造成问题

    #设置 Supervisor

    cp ./webvirtmgr.ini /etc/supervisord.d/webvirtmgr.ini


    #允许连接到httpd 以下为手动打开
    #/usr/sbin/setsebool httpd_can_network_connect true 
    #以下是设置在备置文件中
    setsebool -P httpd_can_network_connect=1

    #开机自动运行 web服务器

    systemctl enable nginx.service

    systemctl enable supervisord.service

    #（1） 生成ssh key
    #建议config文件，并写入配置
    echo "============================Create a key for ssh :======================================"

    su - nginx -s /bin/bash -c 'ssh-keygen&&touch ~/.ssh/config&&echo -e "StrictHostKeyChecking=no\nUserKnownHostsFile=/dev/null" >> ~/.ssh/config'
    su - nginx -s /bin/bash -c "chmod 0600 ~/.ssh/config"
    
}

function config_KVMServer_SSH {
    clear
    #（2）建立 libvirt 帐号 =========================================================
    echo "============================Create a libvirt account in the kvm server :======================================"
    
    host=""
    while [ "$host" == "" ]
    do
        echo "Enter KVM Server:"
        read host
    done

    username=""
    while [ "$username" == "" ]
    do
        echo "Enter a New UserName:"
        read username
    
    
    done

    password=""
    while [ "$password" == "" ]
    do

        echo "Password:"
        read password
        echo "Confirm Password:"
        read confirmPassword
        if [ "$password" != "$confirmPassword" ]
        then
            password=""
        fi
    done



    #（3）远程执行 SSH 命令,配置 KVM Server
    #sshpass -p $Password ssh -o "StrictHostKeyChecking no" $username@$hostname cmd

    #sshpass -p "********" ssh -t root@192.168.20.60 'bash -s' < configKvm.sh $username" "$Password
    
    # 配置 KVM Server
    echo "================Login KVM Server By root. Enter Password Of root.===================="
    ssh -t root@$host 'bash -s' < configkvm.sh $username" "$password
    
    # 把Key复制到 Kvm 服务器
    
    su - nginx -s /bin/bash -c 'sshpass -p "'$password'" ssh-copy-id '$username'@'$host   

    #防火墙设置

    firewall-cmd --add-port=80/tcp --permanent
    firewall-cmd --add-port=80/udp --permanent

    firewall-cmd --add-port=5900/tcp --permanent
    firewall-cmd --add-port=5901/tcp --permanent
    firewall-cmd --add-port=5902/tcp --permanent
    firewall-cmd --add-port=5903/tcp --permanent
    firewall-cmd --add-port=5904/tcp --permanent
    firewall-cmd --add-port=5905/tcp --permanent
    firewall-cmd --add-port=5906/tcp --permanent
    firewall-cmd --add-port=5907/tcp --permanent
    firewall-cmd --add-port=5908/tcp --permanent
    firewall-cmd --add-port=5909/tcp --permanent

    firewall-cmd --add-port=5910/tcp --permanent
    firewall-cmd --add-port=5911/tcp --permanent
    firewall-cmd --add-port=5912/tcp --permanent
    firewall-cmd --add-port=5913/tcp --permanent
    firewall-cmd --add-port=5914/tcp --permanent
    firewall-cmd --add-port=5915/tcp --permanent
    firewall-cmd --add-port=5916/tcp --permanent
    firewall-cmd --add-port=5917/tcp --permanent
    firewall-cmd --add-port=5918/tcp --permanent
    firewall-cmd --add-port=5919/tcp --permanent

    firewall-cmd --reload
    echo "Finish OK! Please Reboot It." 
}

clear
PS3="Enter option:"
select option in "Install Webvirtmgr" "Config KVM Server(SSH)" "Exit Program"
do
    case $option in 
    "Exit Program")
        break;;
    "Install Webvirtmgr")
        install_webvirtmgr
        break ;;
    "Config KVM Server(SSH)")
        config_KVMServer_SSH
        break ;;
    *)
        
        echo "Please Enter option 1-4." ;;
    esac
done






