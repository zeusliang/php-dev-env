# web服务器容器自动创建脚本

# 安装docker
function getDocker(){
	# 根据当前系统发行版本安装docker
	# 1.获取系统发行版本
	# 2.安装docker
	os_distribute_version=$(awk -F\" '/^NAME/{print $2}' /etc/os-release)
	# 当前os为CentOS
	if [[ $os_distribute_version = "CentOS" ]]
	then
		# 运行docker安装脚本
		source ${PWD}/get_docker/get-centos-docker.sh
	fi
	# 当前系统为Debian
	if [[ $os_distribute_version = "Debian" ]]
	then
		source ${PWD}/get_docker/get-debian-docker.sh
	fi

}

# 创建web server容器
function creCon(){
	# 设置容器相关变量
	# 容器名称
	con_name="php7.3-dev"
	# 镜像名称
	con_img_name="php:7.3.7-apache-stretch"
	# 容器权限
	con_grant="--privileged"
	# 容器端口
	port="-p 80:80 -p 8080:8080 -p 8081:8081"
	# 容器数据存储路径
	volume="/var/container/php7.3-dev/data_store/"
	mkdir -p $volume
	cp -rf share $volume
	con_store="${volume}/share:/share"
	# 容器运行模式
	con_mod="-d"

	# 检测docker是否存在
	if [ -e /usr/bin/docker ]
	then
		# 判断容器是否存在
		# 获取容器名称
		get_con_name=$(docker ps -a | grep $con_name)
		# 设置web容器部署脚本路径
		deploy=/share/deploy.sh
		if [[ $get_con_name =~ $con_name ]]
		then
			# 1.存在，则运行部署脚本
			docker exec -it $con_name bash $deploy
		else
			# 2.不存在，创建后运行部署脚本
			con_cre="docker run $con_mod --name $con_name $port -v $con_store $con_grant $con_img_name"
			$con_cre
			if [ $? = 0 ]
			then
				# 容器创建成功，部署容器
				echo "容器创建成功，正在配置中..."
				docker exec -it $con_name bash $deploy
			else
				# 容器创建失败，退出脚本
				echo "容器创建失败"
				exit 0
			fi

		fi
	else
		echo "当前系统未安装docker"
	fi

}

# 运行脚本
getDocker
creCon