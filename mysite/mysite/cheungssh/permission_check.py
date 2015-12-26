#coding:utf-8
from django.http import HttpResponse
import json
def permission_check(perm):
	def wrapper_check(func):
		def check(request,*args,**kws):
			info={'msgtype':'ERR'}
			if not  request.user.has_perm(perm):
				info['content']="您无权访问! 该操作已被审计"
				info=json.dumps(info,encoding='utf-8',ensure_ascii=False)
				return HttpResponse(info)
			else:
				return func(request,*args,**kws)
			
		return check
	return wrapper_check
	
