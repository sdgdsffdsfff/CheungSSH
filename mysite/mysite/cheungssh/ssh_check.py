#!/usr/bin/evn python
#coding:utf8
#张其川

from  key_resolv import  key_resolv

def ssh_check(conf):
	info={"msgtype":"ERR"}
	try:
		username=conf['username']
		password=conf['password']
		port=conf['port']
		ip=conf['ip']
		loginmethod=conf['loginmethod']
		info={"msgtype":"ERR","content":""}
		import paramiko
		ssh=paramiko.SSHClient()
		if loginmethod=='KEY':
			keyfile=conf['keyfile']
			KeyPath= key_resolv(keyfile)
			key=paramiko.RSAKey.from_private_key_file(KeyPath)
			ssh.load_system_host_keys()
			ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
			ssh.connect(ip,port,username,pkey=key)  
                else:
                        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
                        ssh.connect(ip,int(port),username,password)
		info['msgtype']="OK"
	except Exception,e:
		print '检测错误',e
		info['content']=str(e)
	finally:
		ssh.close()
	return info
		
	
	
