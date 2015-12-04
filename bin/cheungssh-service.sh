#!/bin/bash
setenforce 0
start(){
	chmod 755 -R  /var/lib/mysql/  2>/dev/null
	chmod  777 /var/lib/mysql/mysql.sock 2>/dev/null
	echo  "关闭防火墙"
	service iptables stop
	nohup python /home/cheungssh/bin/websocket_server_cheung.py >>/home/cheungssh/logs/web_run.log  2>&1 &
	service mysqld  start &&
	/home/cheungssh/redis-3.0.4/src/redis-server /home/cheungssh/conf/redis.conf   &&
	service httpd start  &&
	if [ $? -ne 0 ]
	then
		echo  "启动以上服务失败，请检查原因"
		exit 1
	else
		dest_mysql_sock='/var/lib/mysql/mysql.sock'
		if [ ! -e  $dest_mysql_sock ]
		then
			mkdir  -p /var/lib/mysql/ 2>/dev/null;chown mysql.mysql /var/lib/mysql/
			if [ -f /etc/my.cnf ]
			then
				cnf="/etc/my.cnf"
			else
				cnf="/etc/mysql/my.cnf"
			fi
			mysql_sock=`grep  -E '^ *socket.*mysql.*sock$' $cnf|awk  -F  '=' 'NR==1{print  $NF}'`
			if [ ! -e $dest_mysql_sock ]
			then
				ln -s $mysql_sock  $dest_mysql_sock
			fi
			
		fi
		if [ $? -ne 0 ]
		then
			echo "Mysql相关信息错误"
			exit 1
		fi
		echo "已启动CheungSSH"
	fi
}
status(){
	pid=`netstat -anplut|grep '0.0.0.0:1337'|awk   '{split($NF,A,"/") ;print A[1]}'`
	if  [[ ! -z $pid ]]
	then
		echo "CheungSSH Web pid($pid)  is running ..."
	else
		echo "No runing"
		exit 2
	fi
	
}
stop(){
	service httpd stop 
	service mysqld stop
	killall  -9 httpd 2>/dev/null
	/home/cheungssh/redis-3.0.4/src/redis-cli -a testpassword shutdown    &&
	netstat -anplut|grep '0.0.0.0:1337'|awk   '{split($NF,A,"/") ;print A[1]}' |xargs kill  -9 {} 2>/dev/null


}
case $1 in
	start)
		stop
		start
	;;
	stop)
		stop
	
		;;
status)
	status
	;;
restart)
	stop
	start
	;;
	*)
		echo "Useage: $0 {start|stop|restart}"""
		exit 1
esac
