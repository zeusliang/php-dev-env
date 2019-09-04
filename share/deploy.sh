# web服务器自动部署脚本

# 配置web服务器
function confServer(){
	# 配置Apache虚拟机
	cp  /share/server-conf/000-default.conf /etc/apache2/sites-enabled/000-default.conf
	# 配置国内软件仓库
	mv /etc/apt/sources.list /etc/apt/sources.list.backup
	cp /share/server-conf/sources.list /etc/apt/sources.list

	# 配置apache重写模块
	ln -s  /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load

	# 设置监听端口
	echo "Listen 8080" >> /etc/apache2/ports.conf
	echo "Listen 8081" >> /etc/apache2/ports.conf
}

# 安装composer
function getComposer(){
	# 设置PHP的配置文件路径
	cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini
	echo "正在安装composer..."
	# 安装composer
	curl -sS https://getcomposer.org/installer | php
	mv composer.phar /usr/bin/composer 
	# 检测安装结果
	if [ -e /usr/bin/composer ]
	then
		# 添加执行权限
		# chmod 775 /usr/bin/composer
		# 配置加速镜像
		composer config -g repo.packagist composer https://packagist.phpcomposer.com
		# composer config -g repo.packagist composer https://packagist.laravel-china.org
		echo "composer安装成功"
	else
		echo "composer安装失败"
	fi
}

# 安装git和unzip
function getTool(){
	# 安装composer 需要的工具
	# 检测git是否安装	
	if [ -e /usr/bin/git ] 
	then
		echo "git 已经安装"
	else
		echo "正在更新apt仓库..."
		# 更新软件
		apt update -y
		if [ $? = 0]
		then
			echo "apt仓库更新成功"
		else
			echo "apt仓库更新失败，请检查网路或apt仓库配置"
		fi
		echo "正在安装 git ..."
		apt install git -y
		if [ $? = 0 ]
		then
			echo "git 安装成功"
		else
			echo "git 安装失败"
		fi
	fi
	
	# 检测unzip是否安装
	if [ -e /usr/bin/unzip ] 
	then
		echo "unzip 已经安装"
	else
		echo "正在安装 unzip"
		apt install unzip -y
		if [ $? = 0 ]
		then
			echo "unzip 安装成功"
		else
			echo "unzip 安装失败"
		fi
	fi
}

# 部署tp5
function getTp5(){
	echo "正在安装tp5..."
	# 使用composer安装tp5
	composer create-project topthink/think  /var/www/html/tp5  --prefer-dist
	# 检测安装结果
	if [ -d /var/www/html/tp5 ]
	then
		# 设置apache日志目录
		mkdir /var/www/html/tp5/apache_logs
		# 设置tp5的数据存储路径
		mv /var/www/html/tp5 /share/tp5
		ln -s /share/tp5 /var/www/html/tp5
		# 
		echo "tp5安装成功"
	else
		echo "tp5安装失败"
	fi
}

# 部署laravel
function getLaravel(){
	echo "正在安装laravel..."
	# 使用composer安装laravel
	composer create-project laravel/laravel  /var/www/html/laravel  --prefer-dist
	# 检测安装结果
	if [ -d /var/www/html/laravel ]
	then
		# 设置apache日志目录
		mkdir /var/www/html/laravel/apache_logs
		# 设置laravel的数据存储路径
		mv /var/www/html/laravel /share/laravel

		# 设置laravel相关目录权限
		# storage
		chmod -R 775 /share/laravel/storage
		chmod 777 /share/laravel/storage/logs
		chmod 777 /share/laravel/storage/framework/*
		# bootstrap/cache
		chmod -R 775 /share/laravel/bootstrap/cache

		ln -s /share/laravel /var/www/html/laravel
		echo "laravel安装成功"
	else
		echo "laravel安装失败"
	fi
}

# 部署test
function getTest(){
	echo "正在安装test..."
	# 使用composer安装test
	# composer create-project laravel/laravel  /var/www/html/laravel  --prefer-dist
	mkdir /var/www/html/test
	# 检测安装结果
	if [ -d /var/www/html/test ]
	then
		# 设置对外访问目录
		mkdir /var/www/html/test/public
		# 设置apache日志目录
		mkdir /var/www/html/test/apache_logs
		# 设置tp5的数据存储路径
		mv /var/www/html/test /share/test
		ln -s /share/test /var/www/html/test
		#
		echo "test安装成功"
	else
		echo "test安装失败"
	fi
}

# 检测容器环境是否配置
function chckServerConf(){
	# 虚拟机配置文件路径
	vm_conf_path=/etc/apache2/sites-enabled/000-default.conf
	# tp5虚拟机目录
	vm_tp5=/var/www/html/tp5/public
	# 获取虚拟机配置
	get_vm_tp5=$(cat $vm_conf_path | grep "$vm_tp5")
	# laravel虚拟机目录
	vm_laravel=/var/www/html/laravel/public
	# 获取虚拟机配置
	get_vm_laravel=$(cat $vm_conf_path | grep "$vm_laravel")
	# 测试虚拟机目录
	vm_test=/var/www/html/test/
	# 获取虚拟机配置
	get_vm_test=$(cat $vm_conf_path | grep "$test")
	# 检测虚拟机配置
	if [[ $get_vm_tp5 =~ $vm_tp5 ]] && [[ $get_vm_laravel =~ $vm_laravel ]] && [[ $get_vm_test =~ $vm_test ]]
	then
		url_tp5="htpp://127.0.0.1"
		url_laravel="htpp://127.0.0.1:8080"
		url_test="htpp://127.0.0.1:8081"
		echo "服务器部署成功，现在你可以访问以下url:"
		echo "tp5:$url_tp5"
		echo "laravel:$url_laravel"
		echo "test:$url_test"
		# 重启apache使配置生效
		apachectl -k restart
	else
		echo "虚拟机配置失败，请联系管理处理该问题"
	fi
}

# 运行脚本
function deployAll(){
	# 检测composer是否安装
	if [ -e /usr/bin/composer ]
	then
		# composer安装成功，脚本继续下行
		echo "composer已经安装"
	else
		# 检测git和unzip是否安装
		getComposer
	fi

	# 检测tp5是否部署
	if [ -d /var/www/html/tp5 ]
	then
		echo "tp5 已经安装"
	else
		# 配置服务器
		confServer
		# 安装composer依赖
		getTool
		# 安装tp5
		getTp5
	fi

	# 检测laravel是否部署
	if [ -d /var/www/html/laravel ]
	then
		echo "laravel 已经安装"
	else
		getLaravel
	fi

	# 检测tp5是否部署
	if [ -d /var/www/html/test ]
	then
		echo "test 已经安装"
	else
		getTest
	fi
}

# 运行脚本
# 部署所有项目
deployAll
# 检测容器环境是否配置
chckServerConf