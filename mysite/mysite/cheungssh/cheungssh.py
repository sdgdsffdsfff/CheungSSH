#coding:utf-8
from django.http import  HttpResponse,HttpResponseRedirect
from django.shortcuts import render_to_response
from django.contrib.auth import authenticate,login,logout
from mysite.cheungssh.models import ServerConf
import FileTransfer,path_search,crond_record
import sys,os,json,random,commands,queue_task,time,threading
from permission_check import permission_check
sys.path.append('/home/cheungssh/bin')
import IP,hwinfo,DataConf,ssh_check
import cheungssh_web,login_check
import re
upload_dir="/home/cheungssh/upload"
keyfiledir="/home/cheungssh/keyfile"
scriptfiledir="/home/cheungssh/scriptfile"
reload(sys)
sys.setdefaultencoding('utf8')
from django.core.cache import cache
from django.views.generic.base import View 
import login_check
import db_to_redis_allconf
crond_file="/home/cheungssh/crond/crond_file"
cmdfile="/home/cheungssh/data/cmd/cmdfile"
def cheungssh_index(request):
	return render_to_response("cheungssh.html")
def cheungssh_login(request):
	info={"msgtype":"ERR","content":"","auth":"no"}
	client_ip=request.META['REMOTE_ADDR']
	print '登录:',client_ip
	try:
		print IP.find(client_ip)
	except Exception,e:
		print '不能解析IP'
	limit_ip='fail.limit.%s'%(client_ip)
	if cache.has_key(limit_ip):
		if cache.get(limit_ip)>4:
			print '该用户IP已经被锁定'
			info['content']="无效登陆"
			cache.incr(limit_ip)
			cache.expire(limit_ip,8640000)
			info=json.dumps(info)
			return HttpResponse(info)
	if request.method=="POST":
		username = request.POST.get("username", False)
		password = request.POST.get("password", False)
		print username,password,request.POST
		user=authenticate(username=username,password=password)
		if user is not None:
			if user.is_active:
				print "成功登陆"
				login(request,user)
				request.session["username"]=username
				info["msgtype"]="OK"
				info['auth']="yes"
				request.session.set_expiry(0)
				if cache.has_key(limit_ip):cache.delete(limit_ip)
				print request.COOKIES,request.session.keys(),request.session['_auth_user_id']
				info['sid']=str(request.session.session_key)
			else:
				
				info["content"]="用户状态无效"
				print info["content"]
		else:
			if cache.has_key(limit_ip):
				cache.incr(limit_ip)
			else:
				cache.set(limit_ip,1,3600)
			info["content"]="用户名或密码错误"
			print info["content"]
			
			
	else:
		try:
			info["content"]="No Get"
		except Exception,e:
			print '错误',e
	info=json.dumps(info)
	response=HttpResponse(info)
	response["Access-Control-Allow-Origin"] = "*"
        response["Access-Control-Allow-Methods"] = "POST"
        response["Access-Control-Allow-Credentials"] = "true"
        return response
	info=json.dumps(info)
	print info
	return HttpResponse(info)
def cheungssh_logout(request):
	info={'msgtype':'OK'}
	if request.user.is_authenticated():
		logout(request)
	info=json.dumps(info)
	callback=request.GET.get('callback')
	if callback is None:
		info=info
	else:
		info="%s(%s)"  % (callback,info)
	return HttpResponse(info)
@login_check.login_check('文件下载到本地')
@permission_check('local_file_download')
def download_file(request):
	info={"msgtype":"ERR","content":""}
	file=request.GET.get('file')
	callback=request.GET.get('callback')
	try:
		file=eval(file)
		if not  type([])==type(file):
			info['content']='传入的参数不是一个[]'
		else:
			info['msgtype']='OK'
	except Exception,e:
		info["content"]="传入的参数不是一个json格式"
	newfile=[]
	for f in file:
		tf=os.path.basename(f.rstrip('/'))  
		newfile.append(tf)
	os.chdir('/home/cheungssh/download/')
	downfile="%s.tar.gz" %str(random.randint(90000000000000000000,99999999999999999999))
	if file:
		cmd="tar zcf  /home/cheungssh/download/%s  " % downfile +  " ".join(newfile)
		T=commands.getstatusoutput(cmd)
		if not  T[0]==0:
			info['content']=T[1]
			info['msgtype']='ERR'
			os.system("/bin/rm %s" % downfile)
		else:
			info["msgtype"]='OK'
			server_head=request.META['HTTP_HOST']
			info["url"]="http://%s/cheungssh/download/file/%s" % (server_head,downfile)
	else:
		info['msgtype']='ERR'
		info['content']="您尚未指定要下载的有效文件,请确认此前下载是否成功"
	info=json.dumps(info,encoding='utf-8',ensure_ascii=False)
	if callback is None:
		info=info
	else:
		info="%s(%s)"  % (callback,info)
	return HttpResponse(info)

	
@login_check.login_check('密钥管理')
def keyshow(request):
	info={"msgtype":"ERR","content":""}
	callback=request.GET.get('callback')
	show_type=request.GET.get('show_type')
	try:
		content=cache.get('keyfilelog')
		if content:
			content=content.values()
		else:
			content=[]
		print content,77777777777
		if show_type=='list':
			keyfile_list={}
			for a in content:
				keyfile_list[a['fid']]=a['filename']
			info['content']=keyfile_list
		else:
			info["content"]=content
		info['msgtype']="OK"
	except Exception,e:
		info["content"]=str(e)
		print e
	info=json.dumps(info)
	if callback is None:
		info=info
	else:
		info="%s(%s)"  % (callback,info)
	return HttpResponse(info)
@login_check.login_check('删除密钥')
@permission_check('cheungssh.key_del')
def delkey(request):
	info={"msgtype":"ERR","content":"","path":""}
	callback=request.GET.get('callback')
	fid=request.GET.get('fid')
	try:
		alllogline=cache.get("keyfilelog")
		if alllogline:
			keyfile=os.path.join(keyfiledir,alllogline[fid]['filename'])
			try:
				os.remove(keyfile)
			except:
				pass
			del alllogline[fid]
			cache.set('keyfilelog',alllogline,3600000)
			info["msgtype"]="OK"
	except Exception,e:
		info["content"]=str(e)
	info=json.dumps(info,encoding='utf-8',ensure_ascii=False)
	if callback is None:
		info=info
	else:
		info="%s(%s)"  % (callback,info)
	return HttpResponse(info)
		
@login_check.login_check('PC上传')
@permission_check('cheungssh.local_file_upload') 
def upload_file_test(request):
	fid=str(random.randint(90000000000000000000,99999999999999999999))
	info={"msgtype":"ERR","content":"","path":""}
	upload_type=request.GET.get('upload_type')
	username=request.user.username
	if request.method=="POST":
		filename=str(request.FILES.get("file"))
		filecontent=request.FILES.get('file').read()
		filesize=  "%sKB" % (float(request.FILES.get('file').size)/float(1024))
		alllogline=cache.get('keyfilelog')
		if not alllogline:
			alllogline={}
		logline={}
		if upload_type=='keyfile':
			logline['time']=time.strftime("%Y-%m-%d %H:%M:%S",time.localtime(time.time()))
			logline['filename']=filename
			logline['username']=username
			logline['fid']=fid
			alllogline[fid]=logline
			cache.set('keyfilelog',alllogline,36000000000000)
			file_position="%s/%s" % (keyfiledir,filename)
		elif upload_type=='script':
			logline['time']=time.strftime("%Y-%m-%d %H:%M:%S",time.localtime(time.time()))
			logline['filename']=filename
			logline['username']=username
			scriptlogline=cache.get('scriptlogline')   
			if scriptlogline is None:scriptlogline={}
			scriptlogline[filename]=logline
			cache.set('scriptlogline',scriptlogline,36000000000000)
			file_position="%s/%s" % (scriptfiledir,filename)
			info['content']=logline
		else:
			file_position="%s/%s" % (upload_dir,filename)
		try:
			t=open(file_position,"wb")
			t.write(filecontent)
			t.close()
			info["msgtype"]="OK"
			info["path"]=file_position
			if upload_type=="keyfile":info=logline
		except Exception,e:
			print e
			info["content"]=str(e)
	info=json.dumps(info)
	response=HttpResponse(info)
        response["Access-Control-Allow-Origin"] = "*"
        response["Access-Control-Allow-Methods"] = "POST"
        response["Access-Control-Allow-Credentials"] = "true"
	response["Access-Control-Allow-Headers"]="Content-Type"
	return response
	try:
		local_upload_all=cache.get('local_upload')
		client_ip=request.META['REMOTE_ADDR']
		if local_upload_all is None:local_upload_all={}
		local_upload={}
		local_upload['username']=username
		local_upload['time']=time.strftime("%Y-%m-%d %H:%M:%S",time.localtime(time.time()))
		local_upload['ip']=client_ip
		local_upload['filename']=filename
		local_upload['filsize']=filesize
		local_upload['fid']=fid
		local_upload_all[fid]=local_upload
		cache.set('local_upload',local_upload_all,3600000000)
	except Exception,e:
		info['content']=str(e)
		print "发生错误",e
	print response
	return response
####
@login_check.login_check('远程下载')
@permission_check('cheungssh.transfile_download')
def filetrans_remote_download(request):
	fid=str(random.randint(90000000000000000000,99999999999999999999))
	info={"msgtype":"OK","fid":fid,"status":"running"}
	host=request.GET.get('host')
	callback=request.GET.get('callback')
	lasttime=time.strftime('%Y-%m-%d %H:%M:%S',time.localtime())
	redis_info={"msgtype":"OK","content":"","progres":"0",'status':"running","lasttime":lasttime}
	cache.set("info:%s" % (fid),redis_info,360)
	username=request.user.username
	FileTransfer.getconf(host,fid,username,"download")
	info=json.dumps(info)
	if callback is None:
		info=info
	else:
		info="%s(%s)"  % (callback,info)
	response=HttpResponse(info)
	response["Access-Control-Allow-Origin"] = "*"
	response["Access-Control-Allow-Methods"] = "POST"
	response["Access-Control-Allow-Credentials"] = "true"
	return response
####
@login_check.login_check('远程上传')
@permission_check('cheungssh.transfile_upload')
def filetrans_remote_upload(request):
	fid=str(random.randint(90000000000000000000,99999999999999999999))
	info={"msgtype":"OK","fid":fid,"status":"running"}
	host=request.GET.get('host')
	callback=request.GET.get('callback')
	lasttime=time.strftime('%Y-%m-%d %H:%M:%S',time.localtime())
	redis_info={"msgtype":"OK","content":"","progres":"0",'status':"running","lasttime":lasttime}
	cache.set("info:%s" % (fid),redis_info,360)
	username=request.user.username
	FileTransfer.getconf(host,fid,username,"upload")
	
	info=json.dumps(info)
	if callback is None:
		info=info
	else:
		info="%s(%s)"  % (callback,info)
	response=HttpResponse(info)
	response["Access-Control-Allow-Origin"] = "*"
	response["Access-Control-Allow-Methods"] = "POST"
	response["Access-Control-Allow-Credentials"] = "true"
	return response
def haha(request):
	return HttpResponse('haha')
@login_check.login_check('命令搜索',False)
def pathsearch(request):
	info={'msgtype':"OK","content":""}
	callback=request.GET.get('callback')
	path=request.GET.get('path')
	pathinfo=path_search.get_query_string(path)
	info['content']=pathinfo
	info=json.dumps(info)
	if callback is None:
		info=info
	else:
		info="%s(%s)"  % (callback,info)
	return HttpResponse(info)


@login_check.login_check('配置修改')
@permission_check('cheungssh.config_modify')
def config_modify(request):
	print 111122
	callback=request.POST.get('callback')
	host=request.POST.get('host')
	username=request.user.username
	info={'msgtype':'ERR'}
	print 77777
	try:
		host=eval(host)
		if not type({})==type(host):
			print '11111111111',host
			raise IOError('数据格式错误，应该是一个{}')
		t_allgroupall=cache.get('allconf')
		id=host['id']
		if t_allgroupall:
			for b in host.keys():
				if b=="ip":
					host[b]==host['ip'].split('@')[-1]
				if b=='id' or b=="owner" or not host[b]:
					print '跳过'
					continue
				else:
					t_allgroupall['content'][id][b]=host[b]
				info['msgtype']='OK'
				cache.set('allconf',t_allgroupall,36000000000000)
		else:
			info['content']='未装载配置'
	except KeyError:
		info['content']="配置不存在"
		print '配置不存在'
	except Exception,e:
		info['content']=str(e)
		print "错误",e
	info=json.dumps(info,encoding='utf-8')
	if callback is None:
		info=info
	else:
		info="%s(%s)"  % (callback,info)
	return HttpResponse(info)
@login_check.login_check('创建服务器')
@permission_check('cheungssh.config_add')
def config_add(request):
	callback=request.POST.get('callback')   
	host=request.POST.get('host')
	username=request.user.username
	info={'msgtype':'ERR'}
	id=int(random.randint(90000000000,99999999999))
	id=json.dumps(id)
	try:
		host=eval(host)
		if not type({})==type(host):raise IOError('数据格式错误，应该是一个{}')
		t_allgroupall=cache.get('allconf')
		host['id']=id 
		host['owner']=username
		if not host.has_key('password'):host['password']=""
		if t_allgroupall:
			t_allgroupall['content'][id]=host
		else:
			t_allgroupall={"msgtype":"OK","content":{}}
			t_allgroupall['content'][id]=host
		info['msgtype']='OK'
		info['id']=id
		cache.set('allconf',t_allgroupall,8640000000)
	except Exception,e:
		info['content']=str(e)
	info=json.dumps(info,encoding='utf-8')
	if callback is None:
		info=info
	else:
		info="%s(%s)"  % (callback,info)
	return HttpResponse(info)
@login_check.login_check('删除服务器')
@permission_check('cheungssh.config_del')
def config_del(request):
	info={'msgtype':'ERR'}
	try:
		host=request.GET.get('host')
		callback=request.GET.get('callback')
		host=eval(host)
		if not type([])==type(host):raise IOError('参数格式错误，应该是一个[]')  
		username=request.user.username
		info={'msgtype':'ERR'}
		try:
			t_allgroupall=cache.get('allconf')
			if t_allgroupall:
				for id in host:
					id=str(id)
					if username==t_allgroupall['content'][id]['owner'] or request.user.is_superuser:
						try:
							del t_allgroupall['content'][id]
						except KeyError:
							pass
						info['msgtype']='OK'
					else:
						info['content']="非法操作"
						break
			cache.set('allconf',t_allgroupall,360000000000)
		except KeyError:
			info['msgtype']='OK'
		except Exception,e:
			info['content']=str(e)
			print "错误",e,host,type(host),id,t_allgroupall
	except Exception,e:
		info['content']=str(e)
	info=json.dumps(info,encoding='utf-8')
	if callback is None:
		info=info
	else:
		info="%s(%s)"  % (callback,info)
	return HttpResponse(info)

@login_check.login_check('删除计划任务')
@permission_check('cheungssh.crond_del')
def delcrondlog(request):
	callback=request.GET.get('callback')
	fid=request.GET.get('fid')
	info={"msgtype":"ERR","content":""}
	delcrond_log=crond_record.crond_del(fid)
	if delcrond_log[0]:
		info['msgtype']='OK'
	else:
		info['content']=delcrond_log[1]
	info=json.dumps(info,encoding='utf-8')
	if callback is None:
		info=info
	else:
		info="%s(%s)"  % (callback,info)
	return HttpResponse(info)
@login_check.login_check('查看计划任务')
@permission_check('cheungssh.crond_show')
def showcrondlog(request):
	callback=request.GET.get('callback')
	info={"msgtype":"OK","content":""}
	crondlog_log=crond_record.crond_show()[1]
	info['content']=crondlog_log
	info=json.dumps(info,encoding='utf-8')
	if callback is None:
		info=info
	else:
		info="%s(%s)"  % (callback,info)
	return HttpResponse(info)
	
@login_check.login_check('创建计划任务')
@permission_check('cheungssh.crond_create')
def crontab(request):
	runmodel="/home/cheungssh/mysite/mysite/cheungssh/"
	callback=request.GET.get('callback')
	value=request.GET.get('value')
	runtime=request.GET.get('runtime')
	runtype=request.GET.get('type')
	info={"msgtype":"ERR","content":""}
	crond_status=commands.getstatusoutput('/etc/init.d/crond status')
	crondlog_value={}
	if not crond_status[0]==0:
		info['content']=crond_status[1]
		print 'crond没有启动'
	else:
		try:
			value=eval(value)
			if not type({})==type(value):
				info['content']="数据类型错误"
			else:
				fid=str(random.randint(90000000000000000000,99999999999999999999)) 
				lasttime=time.strftime('%Y-%m-%d %H:%M:%S',time.localtime())
				value['fid']=fid
				value['user']=request.user.username
				value['status']='未启动'.decode('utf-8')
				value['runtime']=runtime
				value['cmd']=""
				value['lasttime']=lasttime
				value['runtype']=runtype
				value['createtime']=str(time.strftime('%Y-%m-%d %H:%M:%S',time.localtime()))	
				value_to_log={}
				value_tmp=json.dumps(value)
				if runtype=="upload" or runtype=="download":
					value_to_log[value['fid']]=value
					runmodel_program=os.path.join(runmodel,"daemon_FileTransfer.py")
					cmd="""%s  %s '%s' #%s""" % (runtime,runmodel_program,value_tmp,value['fid'])
					a=open(crond_file,'a')
					a.write(cmd+"\n")
					a.close()
					crond_write=commands.getstatusoutput("""/usr/bin/crontab %s""" % (crond_file))
					if int(crond_write[0])==0:
						info['msgtype']='OK'
						crond_record.crond_record(value_to_log)
					else:
						print "加入计划任务失败",crond_write[1],crond_write[0]
						info['content']=crond_write[1]
					print 'Runtime: ',runtime
				elif runtype=="cmd":
					hostinfo=request.GET.get('value')
					try:
						hostinfo=eval(hostinfo)
						value['cmd']=hostinfo['cmd']
						value_to_log[value['fid']]=value
						cmdcontent= "\n%s#%s#%s\n"  %(hostinfo['cmd'],hostinfo['id'],value['fid'])
						try:
							with open(cmdfile,'a') as f:
								f.write(cmdcontent) 
							crondcmd=""" %s %s %s\n"""  % (runtime,'/home/cheungssh/bin/cheungssh_web.py',fid)
							try:
								with open(crond_file,'a') as f:
									f.write(crondcmd)
							
								crond_write=commands.getstatusoutput("""/usr/bin/crontab %s""" % (crond_file))
								if int(crond_write[0])==0:
									info['msgtype']='OK'
									crond_record.crond_record(value_to_log) 
								else:
									print "加入计划任务失败",crond_write[1],crond_write[0]
									info['content']=crond_write[1]
							except Exception,e:
								info['content']=str(e)
						except Exception,e:
							print '写入错误',e
							info['content']=str(e)
					except Exception,e:
						print '发生错误',e
						info['content']=str(e)
				else:
					info['content']="请求任务未知"
					
				
		except Exception,e:
			print "发生错误",e
			info['content']=str(e)
	info=json.dumps(info)
	if callback is None:
		info=info
	else:
		info="%s(%s)"  % (callback,info)
	return HttpResponse(info)
@login_check.login_check('',False)
def local_upload_show(request):
	info={'msgtype':'ERR','content':[]}
	callback=request.GET.get('callback')
	local_upload_all=cache.get('local_upload')
	if local_upload_all:
		info['content']=local_upload_all.values()
	info=json.dumps(info)
	if callback is None:
		info=info
	else:
		info="%s(%s)"  % (callback,info)
	return HttpResponse(info)
@login_check.login_check('执行命令')
@permission_check('cheungssh.excute_cmd')
def excutecmd(request):
	info={'msgtype':'ERR','content':[]}
	callback=request.GET.get('callback')
	cmd=request.GET.get('cmd')
	rid=request.GET.get("rid")
	ie_key=rid
	excute_time=time.strftime("%Y-%m-%d %H:%M:%S",time.localtime(time.time()))
	client_ip=request.META['REMOTE_ADDR']
	client_ip_locat=IP.find(client_ip)
	username=request.user.username
	try:
		server=eval(cmd)
		cmd=server['cmd']
		selectserver=server['selectserver']
		Data=DataConf.DataConf()
		a=threading.Thread(target=cheungssh_web.main,args=(cmd,ie_key,selectserver,Data))
		a.start()
		info['msgtype']="OK"
	except Exception,e:
		info['content']=str(e)
	try:
		allconf=cache.get('allconf')
		allconf_t=allconf['content']
		server_ip_all=[]
		for sid in selectserver.split(','):
			server_ip=allconf_t[sid]['ip']
			server_ip_all.append(server_ip)
		cmd_history=cache.get('cmd_history')
		if cmd_history is None:cmd_history=[]
		tid=str(random.randint(90000000000000000000,99999999999999999999))
		cmd_history_t={
				"tid":tid,
				"excutetime":excute_time,
				"IP":client_ip,
				"IPLocat":client_ip_locat,
				"user":username,
				"servers":server_ip_all,
				"cmd":cmd
			}
		fuck={}
		fuck['go']=client_ip_locat
		cmd_history.insert(0,cmd_history_t)
		cache.set('cmd_history',cmd_history,8640000000)
	except Exception,e:
		print "发生错误",e
		info['msgtype']='ERR'
		info['content']=str(e)
	info=json.dumps(info)
	if callback is None:
		info=info
	else:
		info="%s(%s)"  % (callback,info)
	return HttpResponse(info)
@login_check.login_check('',False)
@permission_check('cheungssh.show_cmd_history')
def cmdhistory(request):
	username=request.user.username
	info={'msgtype':'OK','content':[]}
	callback=request.GET.get('callback')
	pagenum=request.GET.get('pagenum')
	pagesize=request.GET.get('pagesize')
	cmd_history=cache.get('cmd_history')
	if  cmd_history:
		pagenum=int(pagenum)  
		pagesize=int(pagesize)  
		endpage=pagesize*pagenum+1
		if pagenum==1:
			startpage=pagesize*(pagenum-1) 
			endpage=pagesize*pagenum
		else:
			endpage=pagesize*pagenum+1   
			startpage=pagesize*(pagenum-1)+1  
		cmd_history_t=cmd_history[startpage:endpage]
		cmd_history=[]
		for t in cmd_history_t:  
			if username==t["user"] or request.user.is_superuser:
				cmd_history.append(t)
		info['content']=cmd_history
		totalnum=len(cmd_history)
	else:
		totalnum=0
	info['totalnum']=totalnum
	info=json.dumps(info,encoding='utf-8',ensure_ascii=False)
	if callback is None:
		info=info
	else:
		info="%s(%s)"  % (callback,info)
	return HttpResponse(info)

@login_check.login_check()
def get_hwinfo(request):
	info={'msgtype':'ERR','content':[]}
	callback=request.GET.get('callback')
	info['content']=hwinfo.hwinfo(cache)
	info['msgtype']='OK'
	info=json.dumps(info,encoding='utf-8',ensure_ascii=False)
	if callback is None:
		info=info
	else:
		info="%s(%s)"  % (callback,info)
	return HttpResponse(info)
@login_check.login_check('',False)
@permission_check('cheungssh.show_access_page')
def operation_record(request):	
	username=request.user.username
	info={'msgtype':'OK','content':[]}
	pagenum=request.GET.get('pagenum')
	pagesize=request.GET.get('pagesize')
	callback=request.GET.get('callback')
	get_login_record=cache.get('login_record')
	if get_login_record:	
		pagenum=int(pagenum)  
		pagesize=int(pagesize)  
		endpage=pagesize*pagenum+1
		if pagenum==1:
			startpage=pagesize*(pagenum-1) 
			endpage=pagesize*pagenum
		else:
			endpage=pagesize*pagenum+1   
			startpage=pagesize*(pagenum-1)+1  
		query_get_login_tmp=get_login_record[startpage:endpage]  
		query_get_login=[]
		for t in query_get_login_tmp:  
			if username==t["username"] or request.user.is_superuser:
				query_get_login.append(t)
		info['content']=query_get_login
		totalnum=len(query_get_login)
	else:
		totalnum=0
	info['totalnum']=totalnum
	info=json.dumps(info,encoding='utf-8',ensure_ascii=False)
	if callback is None:
		info=info
	else:
		info="%s(%s)"  % (callback,info)
	return HttpResponse(info)
@login_check.login_check('脚本执行')
@permission_check('cheungssh.excutescript')
def excutes_script(request):
	info={'msgtype':'ERR','content':[]}
	callback=request.GET.get('callback')
	info=json.dumps(info,encoding='utf-8',ensure_ascii=False)
	if callback is None:
		info=info
	else:
		info="%s(%s)"  % (callback,info)
	
	return HttpResponse(info)

@login_check.login_check('脚本执行')
@permission_check('cheungssh.scriptfile_add')
def add_script(request):
	username=request.user.username
	info={"msgtype":"ERR"}
	scriptfilecontent=request.POST.get('filecontent')
	filename=request.POST.get('filename')
	callback=request.POST.get('callback')
	try:
		scriptfilepath=os.path.join(scriptfiledir,filename)
		with open(scriptfilepath,'wb')  as f:
			f.write(scriptfilecontent)
		logline={}
		logline['time']=time.strftime("%Y-%m-%d %H:%M:%S",time.localtime(time.time()))
		logline['filename']=filename
		logline['username']=username
		scriptlogline=cache.get('scriptlogline')  
		if scriptlogline is None:scriptlogline={}
		scriptlogline[filename]=logline
		cache.set('scriptlogline',scriptlogline,36000000000000)
		info['msgtype']='OK'
		info['content']=logline
		print '完毕'
	except Exception,e:
		info['content']=str(e)
		print 'cuowu',str(e)
	info=json.dumps(info,encoding='utf-8',ensure_ascii=False)
	if callback is None:
		info=info
	else:
		info="%s(%s)"  % (callback,info)
	return HttpResponse(info)
@login_check.login_check('脚本执行')
@permission_check('cheungssh.scriptfile_show')
def show_scriptcontent(request):
	fid=str(random.randint(90000000000000000000,99999999999999999999))  
	info={'msgtype':'ERR','content':[]}
	callback=request.GET.get('callback')
	edit_type=request.GET.get('edit_type')
	username=request.user.username
	uploadtime=time.strftime("%Y-%m-%d %H:%M:%S",time.localtime(time.time())) 
	filename=request.GET.get('filename')
	try:
		scriptfilepath=os.path.join(scriptfiledir,filename)
		with open(scriptfilepath) as f:
			scriptfilecontent=f.read().strip()
		info['msgtype']='OK'
		info['content']=scriptfilecontent
	except Exception,e:
		info['content']=str(e)
		print  '脚本错误',e,show_scriptlist.__name__
	info=json.dumps(info,encoding='utf-8',ensure_ascii=False)
	if callback is None:
		info=info
	else:
		info="%s(%s)"  % (callback,info)
	return HttpResponse(info)
@login_check.login_check('脚本执行')
@permission_check('cheungssh.scriptfile_list')
def show_scriptlist(request):
	info={"msgtype":"ERR"}
	scriptlogline=cache.get('scriptlogline')
	callback=request.GET.get('callback')
	if scriptlogline:
		info['content']=scriptlogline.values()
	else:
		info['content']=[]
	info['msgtype']='OK'
	info=json.dumps(info,encoding='utf-8',ensure_ascii=False)
	if callback is None:
		info=info
	else:
		info="%s(%s)"  % (callback,info)
	return HttpResponse(info)
def del_script(request):
	
	info={"msgtype":"ERR"}
	try:
		filenames=request.GET.get('filenames') 
		scriptlogline=cache.get('scriptlogline')  
		if scriptlogline:
			for filename in  scriptlogline:
				try:
					del scriptlogline[filename]
				except KeyError:
					pass
				except Exception,e:
					print '错误',e
					info['content']=str(e)
					break
			info['msgtype']='OK'
	except Exception,e:
		info['content']=str(e)
	info=json.dumps(info,encoding='utf-8',ensure_ascii=False)
	if callback is None:
		info=info
	else:
		info="%s(%s)"  % (callback,info)
	return HttpResponse(info)


def onelinenotice(request):
	info={'msgtype':'ERR','content':[]}
	callback=request.GET.get('callback')
	login_check_info=login_check.login_check()(request)
	if not login_check_info[0]:return HttpResponse(login_check_info[1])

'''from auth_check import auth_check
class  test(View,auth_check):
	def get(self,request):
		a=auth_check.__init__(self)
		print a
		return HttpResponse('这是get请求')'''
def t1(request):
	print type(request.user)
	return HttpResponse(request.user)
@login_check.login_check('',False)
def sshcheck(request):
	info={"msgtype":"OK","content":"","status":"ERR"}
	callback=request.GET.get('callback')
	id=request.GET.get('id')
	try:
		conf=db_to_redis_allconf.allhostconf()['content'][id]
		sshcheck=ssh_check.ssh_check(conf)
		if sshcheck['msgtype']=="OK":
			info['status']="OK"
		else:
			info['status']="ERR"
			info['content']=sshcheck['content']
	except KeyError:
		info['msgtype']='ERR'
		info['content']="服务器不存在"
	info=json.dumps(info,encoding='utf-8',ensure_ascii=False)
	if callback is None:
		info=info
	else:
		info="%s(%s)"  % (callback,info)
	return HttpResponse(info)
def cheungssh_index_redirect(request):
	return HttpResponseRedirect('/cheungssh/')
def test_download(request):
	file_name='go'
	response = HttpResponse()
	response['Content_Type']='application/octet-stream'
	response = HttpResponse(mimetype='application/force-download')
	response['Content-Disposition'] = 'attachment; filename=hao'
	response['X-Sendfile'] ='/tmp/passwd'
	return response
"""from sendfile import sendfile
class test_download(View):
    def get(self, request):
        return sendfile(request, '/tmp/passwd')"""
def check_permission(request):
	if request.user.has_perm('cheungssh.excutescript'):
		return HttpResponse('存在')
	else:
		return HttpResponse('不存在')
@login_check.login_check('批量创建服务器')   
@permission_check('cheungssh.batchconfig_web')
def batchconfig_web(request):
	info={"msgtype":"ERR"}
	callback=request.POST.get('callback')
	username=request.user.username
	configcontent=request.POST.get('configcontent')
	allconf=cache.get('allconf')
	confline=''
	batchallconf={}
	try:
		for p in configcontent.split('\n'):
			id=str(random.randint(90000000000000000000,99999999999999999999))
			p=re.sub('^ *','',p)  
			if re.search('^#',p) or re.search('^$',p) :continue
			confline=p.split()  
			
			try:int(confline[1])
			except:raise IOError("端口应该是一个数字: %s" %confline[1])
			if not confline[4]=='KEY' and not confline[4]=='PASSWORD':raise IOError('登录方式[%s]应该是KEY 或者 PASSWORD' % confline[4])
			tconf={
				"id":id,
				"ip":confline[0],
				"port":confline[1],
				"group":confline[2],
				"username":confline[3],
				"loginmethod":confline[4],
				"keyfile":confline[5],  
				"password":confline[6],
				"sudo":confline[7],
				"sudopassword":confline[8],
				"su":confline[9],
				"supassword":confline[10],
				"owner":username
				} 
			
			batchallconf[id]=tconf 
			
		
		if allconf is None:allconf={"content":{},"msgtype":"OK"}
		CONF=allconf['content'].copy()
		CONF.update(batchallconf) 
		allconf['content']=CONF
		cache.set('allconf',allconf,8640000000)
		info['msgtype']='OK'
		print '已经导入'
	except IndexError:
		confline=json.dumps(confline,encoding='utf-8',ensure_ascii=False)
		info['content']='没有足够的参数: %s' % confline
	except Exception,e:
		info['content']=str(e)
	info=json.dumps(info,encoding='utf-8',ensure_ascii=False)
	if callback is None:
		info=info
	else:
		info="%s(%s)"  % (callback,info)
	response=HttpResponse(info)
	response["Access-Control-Allow-Origin"] = "*"
	response["Access-Control-Allow-Methods"] = "POST"
	response["Access-Control-Allow-Credentials"] = "true"
        return response
def redirect_admin(reqeust):
	return HttpResponseRedirect('/cheungssh/admin/')
