#!/bin/bash

echo "正在安装docker..."
# 设置软件仓库源
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
cp ${PWD}/yum/CentOS7-Base-163.repo /etc/yum.repos.d/CentOS-Base.repo

# UNINSTALL OLDER DOCKER
yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine

# SET UP THE REPOSITORY

yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2

yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo


# INDTSLL DOCKER
yum install -y docker-ce docker-ce-cli containerd.io

# SET UP CONTAINER SPEED
if test -e /usr/bin/docker
then
	curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://ef017c13.m.daocloud.io
  # 设置 docker 开机启动
  systemctl enable socker
  # 启动docker
  systmctl start docker  
  echo "docker已安装成功"
else
	echo 'docker安装失败'
fi

