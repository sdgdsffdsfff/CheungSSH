#coding:utf-8
# Create your models here.
from django.db import models


class Main_Conf(models.Model):
	runmod_choices=(("M","多线程"),("S","单线程"))
	RunMode=models.CharField(max_length=1,choices=runmod_choices)
	TimeOut=models.IntegerField(max_length=5)
class ServerConf(models.Model):
	sudo_choices=( ("Y","使用sudo登陆"),("N","普通登陆")    )
	su_choices=( ("Y","su - root 登陆"),("N","普通登陆")    )
	login_type=(   ("KEY","使用PublickKey登陆"),("PASSWORD","使用密码登陆")  )
	IP=models.CharField(max_length=200)
	HostName=models.CharField(max_length=100,null=False,blank=False)
	Port=models.IntegerField(max_length=5)
	Group=models.CharField(max_length=200,null=False,verbose_name="主机组")   
	Username=models.CharField(max_length=200,null=False)
	Password=models.CharField(('password'),max_length=128)
	KeyFile=models.CharField(max_length=100,default="N")
	Sudo=models.CharField(max_length=1,choices=sudo_choices,default="N")
	SudoPassword=models.CharField(max_length=2000,null=True,blank=True)
	Su=models.CharField(max_length=1,choices=su_choices,null=True,blank=True,default="N")
	SuPassword=models.CharField(max_length=2000,null=True,blank=True,default="N")
	LoginMethod=models.CharField(max_length=10,choices=login_type,null=True,blank=True,default="N")
	class Meta:
		permissions=(
				("excute_cmd","可执行命令"),
				("show_cmd_history","查看命令历史"),
				("show_access_page","查看操作记录"),
				("local_file_upload","允许从PC上传文件和密钥"),
				("local_file_download","允许PC下载文件"),
				("transfile_upload","远程文件上传"),
				("transfile_download","远程文件下载"),
				("transfile_history_show","查看文件传输记录"),
				("crond_show","查看计划任务"),
				("crond_del","删除计划任务"),
				("crond_create","创建计划任务"),
				("transfile_keyfile","秘钥上传"),
				("key_del","删除秘钥"),
				("key_list","查看秘钥"),
				("config_add","创建服务器"),
				("config_del","删除服务器"),
				("config_modify","修改服务器"),
				("scriptfile_show","查看脚本内容"),
				("scriptfile_add","创建脚本"),
				("scriptfile_del","删除脚本"),
				("scriptfile_list","显示脚本清单"),
				("batchconfig_web","批量从web创建服务器"),
				("addblackcmd","添加命令黑名单"),
				("delblackcmd","删除命令黑名单 "),
				("listblackcmd","查看命令黑名单"),
				("show_sign_record","查看登录记录"),
				("show_ip_limit","查看锁定的IP记录"),
				("del_ip_limit","删除锁定的IP记录"),
				("show_threshold",'查看登陆失败次数阈值'),
				("set_threshold","设置登录失败次数阈值"),

			)
	def __unicode__(self):
		return self.IP
	
class ServerInfo(models.Model):
	IP=models.OneToOneField(ServerConf)  
	Position=models.TextField(null=True,blank=True)
	Description=models.TextField(null=True,blank=True,default="请在这里写一个对服务器的描述")
	CPU=models.CharField(max_length=20,default="暂无",null=True,blank=True)
	CPU_process_must=models.CharField(max_length=10,default="暂无",null=True,blank=True)
	MEM_process_must=models.CharField(max_length=10,default="暂无",null=True,blank=True)
	Use_CPU=models.CharField(max_length=20,default="暂无",null=True,blank=True)
	uSE_MEM=models.CharField(max_length=20,default="暂无",null=True,blank=True)
	MEM=models.CharField(max_length=20,default="暂无",null=True,blank=True)
	IO=models.CharField(max_length=200,default="暂无",null=True,blank=True)
	Platform=models.CharField(max_length=200,default="暂无",blank=True)
	System=models.CharField(max_length=200,default="暂无",blank=True)
	InBankWidth=models.IntegerField(max_length=20,null=True,blank=True)
	OutBankWidth=models.IntegerField(max_length=20,null=True,blank=True)
	CurrentUser=models.IntegerField(max_length=10,null=True,blank=True)
	def __unicode__(self):
		return self.Position
	
	
	
	





"""class BBS(models.Model):
	title=models.CharField(max_length=64)
	summary=models.CharField(max_length=256,null=True,null=True) 
	content=models.TextField()
	author=models.ForeignKey('BBS_user')
	view_count=models.IntegerField()
	ranking=models.IntegerField()
	created_at=models.DateTimeField()
	choices_show=(  ("N","不显示"),("Y","显示")  )
	show_is=models.CharField(max_length=2,choices=choices_show)
	def  __unicode__(self):
		return self.title  
		
	class Admin:
		pass
class Gategory(models.Model):
	name=models.CharField(max_length=32,unique=True)  
	administrator=models.ForeignKey('BBS_user')
class BBS_user(models.Model):
	
	user=models.OneToOneField(User)
	singnature=models.CharField(max_length=128,default="太懒了，什么都没写")
	photo=models.ImageField(upload_to="imgs",default="default.png")
	def __unicode__(self):
		return self.user.username
		return self.user #注意，下面这种返回方式是错误的，否则会遇到User Fond的错误"""

