#coding:utf-8
import time,IP,json
from django.core.cache import cache
from django.http import HttpResponse
def login_check(page='未知页面',isRecord=True):
	def decorator(func):
		def login_auth_check(request,*args,**kws):
			callback=request.GET.get('callback')
			info={}
			info['accesstime']=time.strftime("%Y-%m-%d %H:%M:%S",time.localtime())
			info['URL']=  "%s?%s"   %(request.META['PATH_INFO'],request.META['QUERY_STRING'])
			info['IP']=request.META['REMOTE_ADDR']
			info['page']=page
			info['IPLocat']=IP.find(info['IP'])
			isAuth=False
			if request.user.is_authenticated():
				info["username"]=request.user.username
				isAuth=True
			else:
				info["username"]="非认证用户"
			login_record=cache.get('login_record')
			if not login_record:login_record=[]
			login_record.insert(0,info)
			if isRecord:
				cache.set('login_record',login_record,86400000) 
			if isAuth:
				return func(request,*args,**kws)
			else:
				backinfo={'msgtype':'login'}
				backinfo=json.dumps(backinfo)
				if callback:
					info="%s(%s)"  % (callback,backinfo)
				else:
					info="%s"  % (backinfo)
				return HttpResponse(info)
			
		return login_auth_check
	return decorator
