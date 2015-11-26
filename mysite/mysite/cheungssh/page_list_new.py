#coding:utf-8


def pagelist(request,datalist):
	info={"msgtype":"ERR"}
	username=request.user.username
	pagenum=request.GET.get('pagenum')
	pagesize=request.GET.get('pagesize')
	try:
		if not  type([])==type(datalist):raise IOError("Redis数据格式错误")
		if  datalist:
			pagenum=int(pagenum)  
			pagesize=int(pagesize)  
			endpage=pagesize*pagenum+1
			if pagenum==1:
				startpage=pagesize*(pagenum-1) 
				endpage=pagesize*pagenum
			else:
				endpage=pagesize*pagenum+1   
				startpage=pagesize*(pagenum-1)+1  
			
			datalist_all=[]
			for t in datalist:  
				try:
					t=eval(t)
				except Exception,e:
					pass
				if not t.has_key('user'):
					if request.user.is_superuser:
						datalist_all.append(t)
				elif username==t["user"] or request.user.is_superuser:
					datalist_all.append(t)
			
			datalist_sub=datalist_all[startpage:endpage]
			#datalist_all.reverse()
			info['content']=datalist_sub
			totalnum=len(datalist_all)
		else:
			totalnum=0
		info["totalnum"]=totalnum
		info["msgtype"]="OK"
	except Exception,e:
		info["content"]=str(e)
	return info
