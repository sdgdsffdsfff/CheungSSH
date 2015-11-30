#coding:utf-8
from django.core.cache import cache
from django.http import  HttpResponse
import re,json
def black_cmd_check(func):
	def wrapper_back_cmd(request,*args,**kws):
		info={'msgtype':'ERR'}
		black_cmd_list=cache.get('black.cmd.list') 
		if request.method=='GET':
		
			callback=request.GET.get('callback')
			servers=request.GET.get('cmd') 			
			force=request.GET.get('force')
<<<<<<< HEAD
			script=False
=======
>>>>>>> origin/master
		else:
			callback=request.POST.get('callback')
			servers=request.POST.get('cmd') 			
			force=request.POST.get('force')
<<<<<<< HEAD
			script=request.POST.get('script')
=======
>>>>>>> origin/master
			
		try:
			servers=eval(servers)
			cmd=servers['cmd']
		except Exception,e:
			cmd=''
		if black_cmd_list is None:black_cmd_list=[]   
		t_cmd=re.sub('^ *| *$','',cmd) 
		t_cmd=re.sub(' +','_',t_cmd)  
		for c in black_cmd_list:
<<<<<<< HEAD
			if re.search(c['cmd'],t_cmd) and not script:  
=======
			if re.search(c['cmd'],t_cmd):
>>>>>>> origin/master
				if not request.user.is_superuser:     
					info['content']='该命令已被阻止 并且被审计!'   
				elif request.user.is_superuser and  force is None:
					info['content']='这是一个敏感命令! 您真的要继续执行吗 ？' 
					info['ask']=True
				else:
					break
				info["msgtype"]="OK"
				info=json.dumps(info,encoding='utf-8',ensure_ascii=False)
				if callback is None:
					info=info
				else:
					info="%s(%s)"  % (callback,info)
				return HttpResponse(info)
				
		return func(request,*args,**kws)
	return wrapper_back_cmd
		
