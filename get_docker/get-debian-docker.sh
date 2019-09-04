# 设置软件仓库源

echo "正在安装docker..."
mv /etc/apt/sources.list /etc/apt/sources.list.backup
cp ${PWD}/apt/sources.list /etc/apt/sources.list

# remove old version of docker
apt-get remove docker docker-engine docker.io containerd runc

### SET UP THE REPOSITORY ###
# Update the apt package index
apt-get update -y
# Install packages to allow apt to use a repository over HTTPS
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common
# Add and verify Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
# apt-key fingerprint 0EBFCD88
# Add repository
add-apt-repository -y \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"

### INSTALL DOCKER ENGINE - COMMUNITY ###
# Update the apt package index
apt-get update
# To install Docker Engine - Community and containerd
apt-get install -y docker-ce docker-ce-cli containerd.io
# Verify and speed up docker
if test -e /usr/bin/docker
then
     curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://ef017c13.m.daocloud.io
     # 设置 docker 开机启动
     systemctl enable socker
     # 启动docker
     systmctl start docker
     echo "docker已安装成功"
else
	   echo "dockers安装失败"
fi
