#!/bin/bash
#Author=Cheung Kei-Chuen
#QQ群=445342415
#coding:utf-8
V=2.0.1
#如果您在使用过程中，遇到了一点点的问题，我都真诚希望您能告诉我！为了改善这个软件， 方便您的工作#
#############################################################################
trap "echo 'CheungSSH官方QQ群: 445342415'" EXIT
cat  <<EOFshow
CheungSSH环境安装如下:
os: centos 5系列   
os: centos 6系列 
os: redhat 5系列 
os: redhat 6系列 
os: ubuntu
python 2.6 或者 2.7
gcc			如果是本地安装方式，需手动安装,联网方式方式则自动安装
python-devel		如果是本地安装方式，需手动安装,联网方式方式则自动安装
openssl-devel		如果是本地安装方式，要手动安装,联网方式方式则自动安装
mysql-devel		如果是本地安装方式，需手动安装,联网方式方式则自动安装
mysql-server		如果是本地安装方式，需手动安装,联网方式方式则自动安装
httpd-devel		如果是本地安装方式，需手动安装,联网方式方式则自动安装
httpd			如果是本地安装方式，需手动安装,联网方式方式则自动安装
setuptools 
django 1.4
django-cors-headers
MySQL-python
redis
pycrypto
paramiko  
django-redis 
django-redis-cache 
pycrypto-on-pypi 
mod_python
EOFshow
read -p  '请知悉以上，然后按Enter继续...' T
#############################################################################
export LANG=zh_CN.UTF-8
if [ `id -u` -ne 0 ]
then
	echo "请使用root权限安装"
	exit 1
fi
echo  "开始安装......"




cp_file(){
setenforce 0
useradd cheungssh -d /home/cheungssh  -s /sbin/nologin 2>/dev/null #该目录是cheungssh的工作目录， 必须创建
mkdir /home/cheungssh 2>/dev/null
echo "正在复制文件..."
if [ `dirname $0` == "." ]
then
	/bin/cp  -r ../* /home/cheungssh/
	if  [ $? -ne  0 ]
	then
		echo  "复制程序文件失败，请检查相关目录是否存在"
		exit 1
	else
		echo "复制程序文件完成"
	fi
		
else
	/bin/cp  -r `dirname  $(dirname  $0)`/* /home/cheungssh/
	if  [ $? -ne  0 ]
	then
		echo  "复制程序文件失败，请检查相关目录是否存在"
		exit 1
	else
		echo "复制程序文件完成"
	fi
fi
/bin/rm -fr  /home/cheungssh/web/cheungssh 2>/dev/null
cd /home/cheungssh/web/  &&
tar xvf cheungssh.html.tgz
if  [ $? -ne 0 ]
then
	echo  "解压失败"
	exit
fi
mkdir -p /home/cheungssh/keyfile
mkdir -p /home/cheungssh/scriptfile
mkdir -p /home/cheungssh/crond
mkdir -p /home/cheungssh/upload
mkdir -p /home/cheungssh/download
mkdir -p /home/cheungssh/conf
mkdir -p /home/cheungssh/version
mkdir -p /home/cheungssh/pid
mkdir -p /home/cheungssh/logs
mkdir -p /home/cheungssh/data
mkdir -p /home/cheungssh/data/cmd/
mkdir -p /home/cheungssh/web/cheungssh/download/
defaultip=`/sbin/ifconfig |grep -v 'inet6'|grep -E '([0-9]{1,3}\.){3}[0-9]{1,3}' -o|grep -vE '^(127|255)|255$'|head -1`
echo "您的服务器IP":
for a in `/sbin/ifconfig |grep -v 'inet6'|grep -E '([0-9]{1,3}\.){3}[0-9]{1,3}' -o|grep -vE '^(127|255)|255$'`
do
	echo  -e "$a"
done
read -p "请输入您的服务器IP地址作为CheungSSH的访问地址: (默认: $defaultip)" ip
ip=${ip:-$defaultip}
read -p  '您需要开启一个HTTP服务来运行CheungSSH的web功能，请您指定HTTP的端口号(默认80) ' port
read -p  "您需要开启一个websocket端口来实时交互命令执行结果，请指定一个端口号(默认1337)" wport
port=${port:-80}
wport=${wport:-1337}
export port
export ip
###
IP="$ip:$port"
WIP="$ip:$wport"
echo "正在配置.."
sed -i  "s/112.74.205.171:800/$IP/g"   /home/cheungssh/web/cheungssh/cheungssh.html         &&
sed -i  "s/112.74.205.171:1337/$WIP/g" /home/cheungssh/web/cheungssh/cheungssh.html         &&
sed -i  "s/1337/$wport/g" /home/cheungssh/bin/cheungssh-service.sh                          &&
sed -i  "s/1337/$wport/g" /home/cheungssh/bin/websocket_server_cheung.py                    &&
sed -i  "s/1337/$wport/g" /home/cheungssh/bin/sendinfo.py
if  [ $? -ne 0 ]
then
	echo  "配置错误"
	exit 1
else
	echo  "完成配置"
fi

##
chmod a+x -R /home/cheungssh/bin/
chown cheungssh.cheungssh -R /home/cheungssh
}
yum_install(){
	echo  "使用Yum安装..."
	yum install  -y gcc python-devel openssl-devel mysql-devel  swig httpd httpd-devel python-pip libevent-devel  MySQL-python 
	if  [ $? -ne 0 ]
	then
		echo "安装失败,重试中...."
		echo  "更新Yum...."
		/bin/cp  -f /home/cheungssh/conf/*repo  /etc/yum.repos.d/
		yum clear all && yum makecache
		echo  "重装yum..."
		yum install  -y gcc python-devel openssl-devel mysql-devel MySQL-python  swig httpd httpd-devel python-pip libevent-devel  --skip-broken
		if  [ $? -ne 0 ]
		then
			echo  "Yum安装又失败了"
			exit 1
		fi
	fi
	if [ `rpm -qa|grep -Eo 'gcc|python-devel|openssl-devel|mysql-devel|swig|httpd|httpd-devel|libevent-devel'|sort|uniq|wc -l` -lt 8 ]
	then
		echo  "更新Yum...."
		/bin/cp  -f /home/cheungssh/conf/*repo  /etc/yum.repos.d/
		yum clear all && yum makecache
		echo  "重装yum..."
		yum install  -y gcc python-devel openssl-devel mysql-devel  MySQL-python swig httpd httpd-devel python-pip libevent-devel --skip-broken
		if [ `rpm -qa|grep -Eo 'gcc|python-devel|openssl-devel|mysql-devel|swig|httpd|httpd-devel|libevent-devel'|sort|uniq|wc -l` -lt 9 ]
		then
			echo "有些包不能安装上...如下:"
			a="gcc python-devel openssl-devel mysql-devel swig httpd httpd-devel libevent-devel MySQL-python "
			for b in $a
			do
				rpm -qa|grep $b
				if  [ $? -ne 0 ]
				then
					echo "$b 不存在"
					exit 1
				fi
			done
			exit
		fi
	fi
	
	which pip
	if [ $? -ne 0 ]
	then
		python /home/cheungssh/soft/get-pip.py
		if [ $? -ne 0 ]
		then
			echo "安装pip失败，尝试第二种方式..."
			pythonv=`echo  "import sys;print sys.version[:3]"|python`
			sh /home/cheungssh/bin/setuptools-0.6c11-py${pythonv}.egg
			if  [ $? -ne 0 ]
			then
				echo "安装setuptools失败"
				exit 1
			fi
			tar xvf  /home/cheungssh/soft/pip-1.3.1.tar.gz  -C  /home/cheungssh/soft/
			if  [ $? -ne 0 ]
			then
				echo "解压失败"
				exit 1
			fi
			cd /home/cheungssh/soft/pip-1.3.1/ && python setup.py install
			if  [ $? -ne 0 ]
			then
				echo "安装pip失败"
				exit 1
			fi
		fi
	fi
	echo "使用pip安装"
	pip install     paramiko  django-redis django-redis-cache  redis   pycrypto-on-pypi  django-cors-headers setuptools
	if  [ $? -ne 0 ]
	then
		echo "安装失败,如果错误信息是 time out 可能是您的网络不好导致的，请重试安装即可"
		exit 1
	fi
	echo  "检查paramiko"
	cat<<EOFparamiko|python
import sys,os
try:
	import paramiko
except AttributeError:
	os.system("""sed  -i '/You should rebuild using libgmp/d;/HAVE_DECL_MPZ_POWM_SEC/d'  /usr/lib*/python*/site-packages/Crypto/Util/number.py   /usr/lib*/python*/site-packages/pycrypto*/Crypto/Util/number.py""")
except:
        sys.exit(1)
EOFparamiko
		###
	tar xvf /home/cheungssh/soft/Django-1.4.22.tar.gz -C  /home/cheungssh/soft/
	cd /home/cheungssh/soft/Django-1.4.22 && python setup.py install
	if [ $? -ne 0 ]
	then
		echo "安装Django失败了，请检查是否有GCC环境"
		exit 1
	fi
	###
	echo "开始安装IP库..."
	cd /home/cheungssh/soft/ && tar xvf IP.tgz  && cd IP && python setup.py install
	if [ $? -ne 0 ]
	then
		echo "安装IP库失败,请检查原因"
		exit 1
	fi
		###
		

		##############安装redis
	echo "正在安装redis服务器"
	tar xvf /home/cheungssh/soft/redis-3.0.4.tar.gz -C /home/cheungssh/  &&
	cd /home/cheungssh/redis-3.0.4  &&  make
	if  [ $? -ne 0 ]
	then
		echo "安装redis服务器失败了，请检查原因"
		exit 1
	fi
		##############安装redis

	read -p  'CheungSSH需要数据库支持，远程或者本地都行，如果没有，程序将为您安装，如果有，您在以后需要填写数据库信息  yes表示有， no表示没有，有还是没有? (yes/no) ' emysql
	emysql=${emysql:-y}
	echo $emysql|grep -iE '^n' -q
	if [ $? -ne 0 ]
	then
		read  -p  '请指定mysql服务器IP : (默认127.0.0.1)' mip
		read -p '请指定mysql登录账户名 (默认root)' musername
		read -p  "请您输入您的mysql登录密码 "  mpassword
		read -p  '请指定mysql端口 (默认3306)' mp
		echo  "测试登录..."
		mip=${mip:-localhost}
		musername=${musername:-root}
		mp=${mp:-3306}
		mcmd="mysql -h${mip} -u${musername}  -p${mpassword} -P${mp}"
		if [[ -z $mpassword ]]
		then
			mysql  -h${mip} -u${musername}  -P${mp}  <<EOF
			read -p  '强烈建议mysql的密码不要为空 (Enter 继续...)' t 
show databases;
EOF
		else
			mysql  -h${mip} -u${musername}  -p${mpassword} -P${mp}  <<EOF
show databases;
EOF
		fi
		if  [ $? -ne 0 ]
		then
			echo  $mcmd
			echo "登录mysql失败，请检查原因， 比如用户名密码是否正确，服务器端口，IP是否正确"
			exit 1
		else
			echo "Mysql配置正确"
		fi
		sed -i  "s/'USER': 'root'/'USER': '$musername'/g"                /home/cheungssh/mysite//mysite/settings.py  &&
		sed -i  "s/'PASSWORD': 'zhang'/'PASSWORD': '$mpassword'/g"     /home/cheungssh/mysite//mysite/settings.py  &&
		sed -i  "s/'HOST': 'localhost'/'HOST': '$mip'/g"             /home/cheungssh/mysite//mysite/settings.py  &&
		sed -i  "s/'PORT': '3306'/'PORT': '$mp'/g"     /home/cheungssh/mysite//mysite/settings.py
		if  [ $? -ne 0 ]
		then
			echo "Django配置数据库错误，请检查配置"
			exit 1
		fi
		if [ -f /etc/init.d/mysql ] && [ ! -f /etc/init.d/mysqld ]
		then
			/bin/mv /etc/init.d/mysql /etc/init.d/mysqld
		fi
	else
		echo "为您自动安装Mysql服务器..."
		yum install mysql-server -y --skip-broken
		if [ $? -ne 0 ]
		then
			echo "安装mysql失败,请检查原因"
			exit 1
		fi
		echo -e "Mysql服务器已经安装完毕\n正在尝试启动Mysql服务器..."
		if [ -f /etc/init.d/mysql ] && [ ! -f /etc/init.d/mysqld ]
		then
			/bin/mv /etc/init.d/mysql /etc/init.d/mysqld
		fi
		/etc/init.d/mysqld restart
		if  [ $? -ne 0 ]
		then
			echo "启动Mysql失败，请检查原因"
			exit 1
		else
			echo "已经启动Mysql服务器"
		fi
		echo  "修改mysql root的密码为zhang"
		if [ `mysqladmin -uroot password zhang` -ne 0 ]
		then
			echo "修改mysql数据库密码失败，请检查原因，比如初始密码是否不是空的."
			exit 1
		fi
		mip='localhost'
		musername="root"
		mpassword="zhang"
		mp=3306
	fi
	#创建cheungssh数据库
	mysql -u${musername}  -h${mip}  -p${mpassword} -P${mp} -e 'create database if not exists cheungssh  default charset utf8'
	if  [ $? -ne 0 ]
	then
		echo "连接数据库错误,请检查原因，端口， 密码， IP是否正确？您是否已经有Mysql服务器？"
		exit 1
	fi
	mysql -uroot -h${mip} -u${musername} -p${mpassword} -P${mp} cheungssh < /home/cheungssh/bin/cheungssh.sql
	if  [ $? -ne 0 ]
	then
		echo "初始化数据库失败，请检查原因"
		exit 1
	else
		echo "初始化数据库完成"
	fi
	########3
	APXS=`which apxs`
	APXS=${APXS:-/usr/sbin/apxs}
	if [ ! -f $APXS ]
	then
		echo  "没有apxs文件"
		exit 1
	fi
	PYTHON=`which python`
	echo "开始安装mod_python"
	cd /home/cheungssh/soft &&
	tar xvf  mod_python-3.4.1.tgz  &&
	cd  mod_python-3.4.1        &&
	./configure    --with-apxs=$APXS    --with-python=$PYTHON   &&
	make && make install
	if  [ $? -ne 0 ]
	then
		echo "安装mod_python失败，请检查原因"
		exit 1
	fi
	##########
	/bin/cp /home/cheungssh/conf/version.py $(dirname `find   /usr/lib*/python*/site-packages/mod_python  -type f -name version.py`)
	if  [ $? -ne 0 ]
	then
		echo "修改mod_python失败，请检查原因"
		exit 1
	fi
	##########
	/bin/cp  /home/cheungssh/conf/httpd.conf /etc/httpd/conf/httpd.conf
	if  [ $? -ne 0 ]
	then
		echo "复制Apache配置文件失败，请检查原因"
		exit 1
	fi
	sed -i  "/^Listen/d" /etc/httpd/conf/httpd.conf  &&
	echo "Listen $port" >> /etc/httpd/conf/httpd.conf
	if  [ $? -ne 0 ]
	then
		echo "修改配置失败,请检查原因"
		exit 1
	fi
	########3
	chown -R  root.cheungssh /etc/httpd/ 2>/dev/null
	chown -R cheungssh.cheungssh /home/cheungssh
	if [ $? -ne 0 ]
	then
		echo "赋权失败 ，请检查目录是否正确"
		exit
	fi
	read -p "您是否要关闭防火墙? (y/n) "  iptables
	iptables=${iptables:-y}
        echo $iptables|grep -iE '^n' -q
        if [ $? -eq 0 ]
        then
		sed  -i '/iptables/d' /home/cheungssh/bin/cheungssh-service.sh
	fi
	widgets=`echo  "from django.forms import widgets;print widgets.__file__.replace('pyc','py')"|python`
	/bin/cp /home/cheungssh/bin/widgets.py $widgets
	/bin/rm -f ${widgets}c 
	echo "安装完成！"
	sh /home/cheungssh/bin/cheungssh-service.sh start
	if  [ $? -ne 0 ]
	then
		echo  -e "\n\n启动HTTP方式 /home/cheungssh/bin/cheungssh-service.sh start"
		echo "启动CheungSSH失败"
		exit 1
	fi
	clear
	read -p "强烈建议首选谷歌浏览器访问! 或者360的极速模式 猎豹,否则不兼容 (Enter继续...)" t
	echo	"安装CheungSSH完毕，请使用:
		用户名: cheungssh
		密  码: cheungssh
		登  录: http://$IP/cheungssh
		管  理: http://$IP/cheungssh/admin

		启动CheungSSH服务: /home/cheungssh/bin/cheungssh-service.sh start"
	###
	exit 
	###############################################yum安装
}
#####################

update(){
	cp_file
		read  -p  '请指定mysql服务器IP : (默认127.0.0.1)' mip
		read -p '请指定mysql登录账户名 (默认root)' musername
		read -p  "请您输入您的mysql登录密码 "  mpassword
		read -p  '请指定mysql端口 (默认3306)' mp
		echo  "测试登录..."
		mip=${mip:-localhost}
		musername=${musername:-root}
		mp=${mp:-3306}
		mcmd="mysql -h${mip} -u${musername}  -p${mpassword} -P${mp}"
		if [[ -z $mpassword ]]
		then
			mysql  -h${mip} -u${musername}  -P${mp}  <<EOF
show databases;
EOF
		else
			mysql  -h${mip} -u${musername}  -p${mpassword} -P${mp}  <<EOF
show databases;
EOF
		fi
		if  [ $? -ne 0 ]
		then
			echo  $mcmd
			echo "登录mysql失败，请检查原因， 比如用户名密码是否正确，服务器端口，IP是否正确"
			exit 1
		else
			echo "Mysql配置正确"
		fi
		sed -i  "s/'USER': 'root'/'USER': '$musername'/g"                /home/cheungssh/mysite//mysite/settings.py  &&
		sed -i  "s/'PASSWORD': 'zhang'/'PASSWORD': '$mpassword'/g"     /home/cheungssh/mysite//mysite/settings.py  &&
		sed -i  "s/'HOST': 'localhost'/'HOST': '$mip'/g"             /home/cheungssh/mysite//mysite/settings.py  &&
		sed -i  "s/'PORT': '3306'/'PORT': '$mp'/g"     /home/cheungssh/mysite//mysite/settings.py
		if  [ $? -ne 0 ]
		then
			echo "Django配置数据库错误，请检查配置"
			exit 1
		fi
	#创建cheungssh数据库
	mysql -uroot -h${mip} -u${musername} -p${mpassword} -P${mp} -e 'create database if not exists cheungssh  default charset utf8'
	if  [ $? -ne 0 ]
	then
		echo "连接数据库错误,请检查原因，端口， 密码， IP是否正确？您是否已经有Mysql服务器？"
		exit 1
	fi
	mysql -uroot -h${mip} -u${musername} -p${mpassword} -P${mp} cheungssh < /home/cheungssh/bin/auth.sql
	if  [ $? -ne 0 ]
	then
		echo "初始化数据库失败，请检查原因"
		exit 1
	else
		echo "初始化数据库完成"
	fi
	echo   -e "更新完毕，请执行 /home/cheungssh/bin/cheungssh-service.sh restart 重启生效\n\t请清除浏览器缓存重新登录"
	echo -e "数据库密码已经恢复初始账号密码，请用账号密码:\n\tcheungssh\n\tcheungssh\n\t登录"
}
main_install(){
cat <<EOFver|python
#coding:utf-8
import sys,time
ver=float(sys.version[:3])
if ver<=2.4:
	print "强烈警告! 您使用的python版本过低,建议升级python版本到2.4以上.\n可以使用yum update python更新"
	sys.exit(1)
EOFver
read -p  "强烈建议您使用yum(Centos)安装CheungSSH,本地软件包安装极为繁琐 (Enter键继续) " haha
read -p  '是否通过Yum网络安装软件包？(y/n) ' netinstall
netinstall=${netinstall:-y}
echo $netinstall|grep -iE '^n' -q
if [ $? -ne 0 ]
then
	yum_install
else
	sh /home/cheungssh/bin/install-CheungSSH.sh.local
fi
}
case  $1 in
	install)
		if  [ `echo  "import platform;print platform.dist()[0]"|python` == "Ubuntu" ]
		then
			cp_file
			bash /home/cheungssh/bin/install-CheungSSH.sh.ubuntu
			exit 1
		fi
		cp_file
		main_install
		;;
	update)
		/bin/cp -f  /home/cheungssh/conf/appendonly.aof  /tmp/appendonly.aof
		/bin/cp -f  /home/cheungssh/conf/dump.rdb /tmp/dump.rdb
		update
		/bin/mv /tmp/appendonly.aof /home/cheungssh/conf/appendonly.aof &&
		/bin/mv /tmp/dump.rdb       /home/cheungssh/conf/dump.rdb
		if [ $? -ne 0 ]
		then
			echo  "更新数据文件失败"
			exit 1
		fi
		echo  "更新完成"
		;;
	*)
		if  [ `echo  "import platform;print platform.dist()[0]"|python` == "Ubuntu" ]
		then
			cp_file
			bash /home/cheungssh/bin/install-CheungSSH.sh.ubuntu
			exit 1
		fi
		cp_file
		main_install
		;;
esac
#delete  from auth_permission where  name like 'Can%';
chmod a+x -R /home/cheungssh/bin/
chown cheungssh.cheungssh -R /home/cheungssh
trap - EXIT
