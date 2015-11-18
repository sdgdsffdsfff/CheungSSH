#coding:utf-8
import json
from django.core.cache import cache
from django.http import HttpResponse
def page_list(request,keyrecord):  
        username=request.user.username
        info={'msgtype':'OK','content':[]}
        callback=request.GET.get('callback')
        pagenum=request.GET.get('pagenum')
        pagesize=request.GET.get('pagesize')
        key_list=cache.get(keyrecord)
        if  key_list:
                pagenum=int(pagenum)  
                pagesize=int(pagesize)  
                endpage=pagesize*pagenum+1
                if pagenum==1:
                        startpage=pagesize*(pagenum-1) 
                        endpage=pagesize*pagenum
                else:
                        endpage=pagesize*pagenum+1   
                        startpage=pagesize*(pagenum-1)+1  
                key_list_t=key_list[startpage:endpage]
                key_list=[]
                for t in key_list_t:  
                        if username==t["owner"] or request.user.is_superuser:
                                key_list.append(t)
                info['content']=key_list
                totalnum=len(key_list)
        else:
                totalnum=0
        info['totalnum']=totalnum
        info=json.dumps(info,encoding='utf-8',ensure_ascii=False)
        if callback is None:
                info=info
        else:
                info="%s(%s)"  % (callback,info)
        return HttpResponse(info)
