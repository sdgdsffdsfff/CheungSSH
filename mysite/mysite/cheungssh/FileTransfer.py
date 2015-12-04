#/usr/bin/python
#coding:utf8
import paramiko,os,re,sys,error_linenumber,threading,functools,json
import db_to_redis,time,socket,key_resolv
from cheunglog import log
import sync_dir
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "mysite.settings")
sys.path.append('/home/cheungssh/mysite')
from django.core.cache import cache
from mysite.cheungssh.models import ServerConf
download_dir="/home/cheungssh/download/"
from sftp_download_dir import cheungssh_sftp
def set_progres(fid,filenum,ifile,isdir,transferred, toBeTransferred):
	lasttime=time.strftime('%Y-%m-%d %H:%M:%S',time.localtime())
	info={"fid":fid,"msgtype":"OK","content":"","progres":"","allsize":"",'status':"running","lasttime":lasttime}
	cache_size_id="fid:size:%s" %(fid)
	if isdir:
		allsize=filenum
		nowsize=ifile
		progres="%0.2f" % (float(nowsize)/float(allsize)*100)
		print '::::%s:::%s::::::::%s' %(nowsize,allsize,progres)
	else:
		allsize=toBeTransferred
		nowsize=transferred
		allsize+=0.0001
		progres="%0.2f" % (float(nowsize)/float(allsize)/filenum *100)
		if transferred==toBeTransferred:
			info['status']='OK'
			info['msgtype']='OK'
			progres=100
	if progres=="100.00":info["msgtype"]="OK"
	info['allsize']=allsize
	info["progres"]=progres
	try:
		cache.set("info:%s"%(fid),info,600)
		cache.set(cache_size_id,allsize,360000000)
		print info,6666666666666666666666666666666666666666666
	except Exception,e:
		print '发生错误',e
		pass
def DownFile(dfile,sfile,username,password,ip,port,su,supassword,sudo,sudopassword,loginmethod,keyfile,fid,user):
	socket.setdefaulttimeout(3)
	dfile=os.path.basename(dfile)
	dfile=os.path.join(download_dir,dfile)
	model="transfile_downfile"
	info={"msgtype":"OK","content":"","status":"running","progres":"0"}
	translog=[]
	lasttime=time.strftime('%Y-%m-%d %H:%M:%S',time.localtime())
	logline={"fid":fid,"action":"download","time":time.strftime('%Y-%m-%d %H:%M:%S',time.localtime()),"ip":ip,"sfile":sfile,"dfile":dfile,"result":"ERR","user":user,"msg":"","size":"0KB","lasttime":lasttime}

	try:
		t=paramiko.Transport((ip,int(port)))
		if loginmethod=="key".upper():
			keyfile=key_resolv.key_resolv(keyfile,cache)
			key=paramiko.RSAKey.from_private_key_file(keyfile)
			t.connect(username = username,pkey=key)
		else:
			t.connect(username = username,password = password)
		callback_info = functools.partial(set_progres,fid,1,1,False)
		sftp = paramiko.SFTPClient.from_transport(t)
		try:
			sftp.listdir(sfile)
			cheungssh_sftp(fid,ip,username,sfile,dfile,set_progres,port,loginmethod,password,keyfile)
			return 
		except Exception,e:
			if e.errno==2:
				pass
			else:
				raise IOError(e)
		sftp.get(sfile,"%s.%s" %(dfile,ip),callback=callback_info)
		log(model,"OK")
		info['status']='OK'
		logline["result"]="OK"
		cache_size_id="fid:size:%s" %(fid)
		cache_size=cache.get(cache_size_id)
		if cache_size is None:
			cache_size=0
		t_size=float(cache_size)/float(1024)
		logline['size']="%0.2fKB"  %t_size
		cache_translog=cache.get("translog")
		if  cache_translog:
			cache_translog.append(logline)
		else:
			translog.append(logline)
			cache_translog=translog
		cache.set("translog",cache_translog,3600000000)
	except Exception,e:
		msg=str(e)
		print msg
		info["content"]=msg
		info["status"]='ERR'
		log(model,msg)
		cache.set("info:%s"%(fid),info,360000)
		logline["result"]="ERR"
		logline["msg"]=msg
		cache_translog=cache.get("translog")
		print "抓取到异常...",e
		logline["result"]=msg
	
	




def UploadFile(dfile,sfile,username,password,ip,port,su,supassword,sudo,sudopassword,loginmethod,keyfile,fid,user):
	print "开始上传..........."
	socket.setdefaulttimeout(3)
	model="transfile_getfile_upload"
	info={"msgtype":"OK","content":"","status":"running","progres":"0"}
	translog=[]
	lasttime=time.strftime('%Y-%m-%d %H:%M:%S',time.localtime())
	logline={"fid":fid,"action":"upload","time":time.strftime('%Y-%m-%d %H:%M:%S',time.localtime()),"ip":ip,"sfile":sfile,"dfile":dfile,"result":"ERR","user":user,"msg":"","size":"0KB","lasttime":lasttime}
	try:
		t=paramiko.Transport((ip,int(port)))
		if loginmethod=="key".upper():
			print "key登陆"
			keyfile=key_resolv.key_resolv(keyfile,cache)
			key=paramiko.RSAKey.from_private_key_file(keyfile)
			t.connect(username = username,pkey=key)
		else:
			print "密码登陆"
			t.connect(username = username,password = password)
		
		if os.path.isdir(sfile):
			#(sdir,ddir,username,password,ip,loginmethod,keyfile,port=22,force=True,callback_info):
			print " [%s]" % password
			sync_dir.UploadFile(sfile,dfile,username,password,ip,loginmethod,keyfile,fid,set_progres,port,True)
			pass
		else:
			
			sftp = paramiko.SFTPClient.from_transport(t)
			if dfile.endswith('/'):
				try:
					sftp.listdir(dfile)
				except Exception,e:
					raise IOError("%s 目录不存在" %(dfile))
			try:
				sftp.listdir(dfile)
				dfile=os.path.join(dfile,os.path.basename(sfile))
			except Exception,e:
				pass
			print sfile,dfile
			callback_info = functools.partial(set_progres,fid,1,1,False)
			sftp.put(sfile,dfile,callback=callback_info)
			log(model,"OK")
			logline["result"]="OK"
			info["status"]="OK"
			info["msgtype"]="OK"
			cache_size_id="fid:size:%s" %(fid)
			cache_size=cache.get(cache_size_id)
			if cache_size is None:
				cache_size=0
			t_size=float(cache_size)/float(1024)
			logline['size']="%0.2fKB"  %t_size
			cache_translog=cache.get("translog")
			if  cache_translog:
				print  888888888
				cache_translog.append(logline)
			else:
				print  9999999999
				translog.append(logline)
				cache_translog=translog
			cache.set("translog",cache_translog,3600000000)
	except Exception,e:
		print "报错",e
		msg=str(e)
		print msg
		info["content"]=msg
		log(model,msg)
		cache.set("info:%s"%(fid),info,360000)
		logline["result"]="ERR"
		info["msgtype"]="OK"
		info["status"]="ERR"
		logline["msg"]=msg
		print "抓取到异常...",e
		logline["result"]=msg
		cache_translog=cache.get("translog")
		if  cache_translog:
			cache_translog.append(logline)
		else:
			translog.append(logline)
			cache_translog=translog
		cache.set("translog",cache_translog,3600000000)
		cache.set("info:%s"%(fid),info,600)
		return error_linenumber.get_linen_umber_function_name()[1]
	else:
		t.close()
def resove_conf(conf,fid,user,action):
	print conf,99999999999999999999999999999999999999999999999999999999,"开始解析"
	model="transfile_getfile_resove_conf"
	info={"msgtype":"ERR","content":""}
	try:
		id=conf["id"]
		dfile=conf["dfile"]
		sfile=conf["sfile"]
		username=conf["username"]
		password=conf["password"]
		ip=conf["ip"]
		port=conf["port"]
		try:
			su=conf["su"]
		except KeyError:
			su='N'
		try:
			supassword=conf["sudopassword"]
		except KeyError:
			supassword=""
		try:
			sudo=conf["sudo"]
		except KeyError:
			sudo="N"
		try:
			sudopassword=conf["password"]
		except KeyError:
			sudopassword=""
		loginmethod=conf["loginmethod"]
		try:
			keyfile=conf["keyfile"]
		except KeyError:
			keyfile=""
		print "解析wanle ",5555555555555555555555555,conf
	except Exception,e:
		print "报错",e,11111111111111111111111111111111111111111111
		msg=str(e)
		log(model,msg)
		info["content"]=msg
		cache.set("info:%s" % (fid),info,360000)
		return error_linenumber.get_linen_umber_function_name()[1]
	if action=="upload":
		b=threading.Thread(target=UploadFile,args=(dfile,sfile,username,password,ip,port,su,supassword,sudo,sudopassword,loginmethod,keyfile,fid,user))
	else:
		b=threading.Thread(target=DownFile,args=(dfile,sfile,username,password,ip,port,su,supassword,sudo,sudopassword,loginmethod,keyfile,fid,user))
		
	b.start()
def getconf(host,fid,user,action):
	model="getconf"
	try:
		if not type({})==type(host):
			host=eval(host)
			if not type(host)==type({}):
				log(model,"配置信息错误， 不是一个dict格式")
				return False
	except Exception,e:
		log(model,str(e))
		print "有错误",e
		return False
	try:
		try:
			hostconf=cache.get('allconf')
		except Exception,e:
			log(model,str(e))
			print e,66666666666,'错误'
		hostconf=hostconf['content'][host['id']]
		print hostconf,"这是提取的配置"
	except Exception,e:
		print "发生错误",e
		log(model,str(e))
		print e
		return False
	hostconf["sfile"]=host["sfile"]
	if action=="download":
		hostconf["dfile"]=os.path.basename(host["sfile"])
	else:
		hostconf["dfile"]=host["dfile"]
	resove_conf(hostconf,fid,user,action)
def translog(request):
	callback=request.GET.get("callback")
	cache_translog=cache.get("translog")
	if cache_translog:
		return HttpResponse(callback+  "("  + cache_translog +  ")")
	else:
		cache_translog=[]
		return HttpResponse(callback+  "("  + cache_translog +  ")")
