#coding:utf-8
from django.core.cache import cache
from django.http import  HttpResponse
import re,json
def black_cmd_check(func):
	def wrapper_back_cmd(request,*args,**kws):
		info={'msgtype':'ERR'}
		servers=request.GET.get('cmd') 			
		black_cmd_list=cache.get('black.cmd.list') 
		try:
			servers=eval(servers)
			cmd=servers['cmd']
		except Exception,e:
			cmd=''
		if black_cmd_list is None:black_cmd_list=[]   
		t_cmd=re.sub('^ *| *$','',cmd) 
		t_cmd=re.sub(' +','_',t_cmd)  
		for c in black_cmd_list:
			if re.search(c['cmd'],t_cmd) and not request.user.is_superuser:     
				info['content']='该命令已被阻止 并且被审计!'   
				info=json.dumps(info,encoding='utf-8',ensure_ascii=False)
				return HttpResponse(info)
		return func(request,*args,**kws)
	return wrapper_back_cmd
		
