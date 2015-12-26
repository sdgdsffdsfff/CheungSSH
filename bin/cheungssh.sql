-- MySQL dump 10.13  Distrib 5.1.73, for redhat-linux-gnu (x86_64)
--
-- Host: localhost    Database: cheungssh
-- ------------------------------------------------------
-- Server version	5.1.73-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `auth_group`
--

DROP TABLE IF EXISTS `auth_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auth_group` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(80) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_group`
--

LOCK TABLES `auth_group` WRITE;
/*!40000 ALTER TABLE `auth_group` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_group` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_group_permissions`
--

DROP TABLE IF EXISTS `auth_group_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auth_group_permissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `group_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `group_id` (`group_id`,`permission_id`),
  KEY `auth_group_permissions_bda51c3c` (`group_id`),
  KEY `auth_group_permissions_1e014c8f` (`permission_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_group_permissions`
--

LOCK TABLES `auth_group_permissions` WRITE;
/*!40000 ALTER TABLE `auth_group_permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_group_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_permission`
--

DROP TABLE IF EXISTS `auth_permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auth_permission` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `content_type_id` int(11) NOT NULL,
  `codename` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `content_type_id` (`content_type_id`,`codename`),
  KEY `auth_permission_e4470c6e` (`content_type_id`)
) ENGINE=MyISAM AUTO_INCREMENT=61 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_permission`
--

LOCK TABLES `auth_permission` WRITE;
/*!40000 ALTER TABLE `auth_permission` DISABLE KEYS */;
INSERT INTO `auth_permission` VALUES (25,'可执行命令',8,'excute_cmd'),(26,'查看命令历史',8,'show_cmd_history'),(27,'查看操作记录',8,'show_access_page'),(28,'允许从PC上传文件和密钥',8,'local_file_upload'),(29,'允许PC下载文件',8,'local_file_download'),(30,'远程文件上传',8,'transfile_upload'),(31,'远程文件下载',8,'transfile_download'),(32,'查看文件传输记录',8,'transfile_history_show'),(33,'查看计划任务',8,'crond_show'),(34,'删除计划任务',8,'crond_del'),(35,'创建计划任务',8,'crond_create'),(36,'秘钥上传',8,'transfile_keyfile'),(37,'删除秘钥',8,'key_del'),(38,'查看秘钥',8,'key_list'),(39,'创建服务器',8,'config_add'),(40,'删除服务器',8,'config_del'),(41,'修改服务器',8,'config_modify'),(42,'查看脚本内容',8,'scriptfile_show'),(43,'创建脚本',8,'scriptfile_add'),(44,'删除脚本',8,'scriptfile_del'),(45,'显示脚本清单',8,'scriptfile_list'),(46,'批量从web创建服务器',8,'batchconfig_web'),(47,'添加命令黑名单',8,'addblackcmd'),(48,'删除命令黑名单 ',8,'delblackcmd'),(49,'查看命令黑名单',8,'listblackcmd'),(50,'查看登录记录',8,'show_sign_record'),(51,'查看锁定的IP记录',8,'show_ip_limit'),(52,'删除锁定的IP记录',8,'del_ip_limit'),(53,'查看登陆失败次数阈值',8,'show_threshold'),(54,'设置登录失败次数阈值',8,'set_threshold');
/*!40000 ALTER TABLE `auth_permission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_user`
--

DROP TABLE IF EXISTS `auth_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auth_user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(30) NOT NULL,
  `first_name` varchar(30) NOT NULL,
  `last_name` varchar(30) NOT NULL,
  `email` varchar(75) NOT NULL,
  `password` varchar(128) NOT NULL,
  `is_staff` tinyint(1) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `is_superuser` tinyint(1) NOT NULL,
  `last_login` datetime NOT NULL,
  `date_joined` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_user`
--

LOCK TABLES `auth_user` WRITE;
/*!40000 ALTER TABLE `auth_user` DISABLE KEYS */;
INSERT INTO `auth_user` VALUES (1,'cheungssh','','','sQ@q.com','pbkdf2_sha256$10000$dx7FZocLn2oq$mabr888RKSjOjzOeR4vjxvxRomhA3cWCqiNS4pGYi+A=',1,1,1,'2015-12-06 01:45:17','2015-12-03 09:41:28');
/*!40000 ALTER TABLE `auth_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_user_groups`
--

DROP TABLE IF EXISTS `auth_user_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auth_user_groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `group_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`,`group_id`),
  KEY `auth_user_groups_fbfc09f1` (`user_id`),
  KEY `auth_user_groups_bda51c3c` (`group_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_user_groups`
--

LOCK TABLES `auth_user_groups` WRITE;
/*!40000 ALTER TABLE `auth_user_groups` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_user_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_user_user_permissions`
--

DROP TABLE IF EXISTS `auth_user_user_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auth_user_user_permissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`,`permission_id`),
  KEY `auth_user_user_permissions_fbfc09f1` (`user_id`),
  KEY `auth_user_user_permissions_1e014c8f` (`permission_id`)
) ENGINE=MyISAM AUTO_INCREMENT=126 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_user_user_permissions`
--

LOCK TABLES `auth_user_user_permissions` WRITE;
/*!40000 ALTER TABLE `auth_user_user_permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_user_user_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cheungssh_main_conf`
--

DROP TABLE IF EXISTS `cheungssh_main_conf`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cheungssh_main_conf` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `RunMode` varchar(1) NOT NULL,
  `TimeOut` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cheungssh_main_conf`
--

LOCK TABLES `cheungssh_main_conf` WRITE;
/*!40000 ALTER TABLE `cheungssh_main_conf` DISABLE KEYS */;
/*!40000 ALTER TABLE `cheungssh_main_conf` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cheungssh_serverconf`
--

DROP TABLE IF EXISTS `cheungssh_serverconf`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cheungssh_serverconf` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `IP` varchar(200) NOT NULL,
  `HostName` varchar(100) NOT NULL,
  `Port` int(11) NOT NULL,
  `Group` varchar(200) NOT NULL,
  `Username` varchar(200) NOT NULL,
  `Password` varchar(128) NOT NULL,
  `KeyFile` varchar(100) NOT NULL,
  `Sudo` varchar(1) NOT NULL,
  `SudoPassword` varchar(2000) DEFAULT NULL,
  `Su` varchar(1) DEFAULT NULL,
  `SuPassword` varchar(2000) DEFAULT NULL,
  `LoginMethod` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cheungssh_serverconf`
--

LOCK TABLES `cheungssh_serverconf` WRITE;
/*!40000 ALTER TABLE `cheungssh_serverconf` DISABLE KEYS */;
/*!40000 ALTER TABLE `cheungssh_serverconf` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cheungssh_serverinfo`
--

DROP TABLE IF EXISTS `cheungssh_serverinfo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cheungssh_serverinfo` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `IP_id` int(11) NOT NULL,
  `Position` longtext,
  `Description` longtext,
  `CPU` varchar(20) DEFAULT NULL,
  `CPU_process_must` varchar(10) DEFAULT NULL,
  `MEM_process_must` varchar(10) DEFAULT NULL,
  `Use_CPU` varchar(20) DEFAULT NULL,
  `uSE_MEM` varchar(20) DEFAULT NULL,
  `MEM` varchar(20) DEFAULT NULL,
  `IO` varchar(200) DEFAULT NULL,
  `Platform` varchar(200) NOT NULL,
  `System` varchar(200) NOT NULL,
  `InBankWidth` int(11) DEFAULT NULL,
  `OutBankWidth` int(11) DEFAULT NULL,
  `CurrentUser` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `IP_id` (`IP_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cheungssh_serverinfo`
--

LOCK TABLES `cheungssh_serverinfo` WRITE;
/*!40000 ALTER TABLE `cheungssh_serverinfo` DISABLE KEYS */;
/*!40000 ALTER TABLE `cheungssh_serverinfo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `corsheaders_corsmodel`
--

DROP TABLE IF EXISTS `corsheaders_corsmodel`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `corsheaders_corsmodel` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cors` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `corsheaders_corsmodel`
--

LOCK TABLES `corsheaders_corsmodel` WRITE;
/*!40000 ALTER TABLE `corsheaders_corsmodel` DISABLE KEYS */;
/*!40000 ALTER TABLE `corsheaders_corsmodel` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_admin_log`
--

DROP TABLE IF EXISTS `django_admin_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `django_admin_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `action_time` datetime NOT NULL,
  `user_id` int(11) NOT NULL,
  `content_type_id` int(11) DEFAULT NULL,
  `object_id` longtext,
  `object_repr` varchar(200) NOT NULL,
  `action_flag` smallint(5) unsigned NOT NULL,
  `change_message` longtext NOT NULL,
  PRIMARY KEY (`id`),
  KEY `django_admin_log_fbfc09f1` (`user_id`),
  KEY `django_admin_log_e4470c6e` (`content_type_id`)
) ENGINE=MyISAM AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_admin_log`
--

LOCK TABLES `django_admin_log` WRITE;
/*!40000 ALTER TABLE `django_admin_log` DISABLE KEYS */;
INSERT INTO `django_admin_log` VALUES (1,'2015-12-03 09:42:24',1,3,'2','t',1,''),(2,'2015-12-03 09:42:42',1,3,'2','t',2,'已修改 password 和 user_permissions 。'),(3,'2015-12-03 09:48:35',1,3,'2','t',2,'已修改 password 和 user_permissions 。'),(4,'2015-12-03 10:00:17',1,3,'2','t',2,'已修改 password 和 user_permissions 。'),(5,'2015-12-03 10:01:17',1,3,'2','t',2,'已修改 password 和 user_permissions 。'),(6,'2015-12-03 10:05:00',1,3,'2','t',2,'已修改 password 和 user_permissions 。'),(7,'2015-12-03 10:11:03',1,3,'2','t',2,'已修改 password 和 user_permissions 。'),(8,'2015-12-05 11:42:00',1,3,'2','t',3,'');
/*!40000 ALTER TABLE `django_admin_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_content_type`
--

DROP TABLE IF EXISTS `django_content_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `django_content_type` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `app_label` varchar(100) NOT NULL,
  `model` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `app_label` (`app_label`,`model`)
) ENGINE=MyISAM AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_content_type`
--

LOCK TABLES `django_content_type` WRITE;
/*!40000 ALTER TABLE `django_content_type` DISABLE KEYS */;
INSERT INTO `django_content_type` VALUES (1,'permission','auth','permission'),(2,'group','auth','group'),(3,'user','auth','user'),(4,'content type','contenttypes','contenttype'),(5,'session','sessions','session'),(6,'cors model','corsheaders','corsmodel'),(7,'main_ conf','cheungssh','main_conf'),(8,'server conf','cheungssh','serverconf'),(9,'server info','cheungssh','serverinfo'),(10,'log entry','admin','logentry');
/*!40000 ALTER TABLE `django_content_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_session`
--

DROP TABLE IF EXISTS `django_session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `django_session` (
  `session_key` varchar(40) NOT NULL,
  `session_data` longtext NOT NULL,
  `expire_date` datetime NOT NULL,
  PRIMARY KEY (`session_key`),
  KEY `django_session_c25c2c28` (`expire_date`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_session`
--

LOCK TABLES `django_session` WRITE;
/*!40000 ALTER TABLE `django_session` DISABLE KEYS */;
INSERT INTO `django_session` VALUES ('6046062f0e44cba3fa7d2c25dceae0b1','YWVhYTgzZDMxMjljZjA5NmI5MzQyNDQ3YWRiNzI1YTcwODU3NjJkNTqAAn1xAShVCHVzZXJuYW1l\ncQJYCQAAAGNoZXVuZ3NzaHEDVQ1fYXV0aF91c2VyX2lkcQSKAQFVEl9hdXRoX3VzZXJfYmFja2Vu\nZHEFVSlkamFuZ28uY29udHJpYi5hdXRoLmJhY2tlbmRzLk1vZGVsQmFja2VuZHEGVQ9fc2Vzc2lv\nbl9leHBpcnlxB0sAdS4=\n','2015-12-17 10:40:39'),('747059c12bfe4a9b036fd5ddaba303fc','NTViZjNkMWY3YmEyMzhmZTAwYzVlZjU5NWRiNzAyNTE5YjQwNGZkMTqAAn1xAShVCHVzZXJuYW1l\ncQJYAQAAAHRVD19zZXNzaW9uX2V4cGlyeXEDSwBVEl9hdXRoX3VzZXJfYmFja2VuZHEEVSlkamFu\nZ28uY29udHJpYi5hdXRoLmJhY2tlbmRzLk1vZGVsQmFja2VuZHEFVQ1fYXV0aF91c2VyX2lkcQaK\nAQJ1Lg==\n','2015-12-17 09:42:56'),('66c85d372c328c179ebdbe3779096304','NTViZjNkMWY3YmEyMzhmZTAwYzVlZjU5NWRiNzAyNTE5YjQwNGZkMTqAAn1xAShVCHVzZXJuYW1l\ncQJYAQAAAHRVD19zZXNzaW9uX2V4cGlyeXEDSwBVEl9hdXRoX3VzZXJfYmFja2VuZHEEVSlkamFu\nZ28uY29udHJpYi5hdXRoLmJhY2tlbmRzLk1vZGVsQmFja2VuZHEFVQ1fYXV0aF91c2VyX2lkcQaK\nAQJ1Lg==\n','2015-12-17 09:58:02'),('68c9a3b68f3643a33bbaca9d80e95060','NTViZjNkMWY3YmEyMzhmZTAwYzVlZjU5NWRiNzAyNTE5YjQwNGZkMTqAAn1xAShVCHVzZXJuYW1l\ncQJYAQAAAHRVD19zZXNzaW9uX2V4cGlyeXEDSwBVEl9hdXRoX3VzZXJfYmFja2VuZHEEVSlkamFu\nZ28uY29udHJpYi5hdXRoLmJhY2tlbmRzLk1vZGVsQmFja2VuZHEFVQ1fYXV0aF91c2VyX2lkcQaK\nAQJ1Lg==\n','2015-12-17 10:09:05'),('c06364514871a4521ee8df260fe91eb9','ZTJjNTY1Yzk2ZWFhY2Q0ODBiZDJmNGRlNTE3YTY5ZDhjMzNkYTVlMjqAAn1xAShVCHVzZXJuYW1l\ncQJYCQAAAGNoZXVuZ3NzaHEDVQ9fc2Vzc2lvbl9leHBpcnlxBEsAVRJfYXV0aF91c2VyX2JhY2tl\nbmRxBVUpZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmRxBlUNX2F1dGhf\ndXNlcl9pZHEHigEBdS4=\n','2015-12-18 03:22:33'),('3a24d6a635ad291afd80a6d138268434','ZTJjNTY1Yzk2ZWFhY2Q0ODBiZDJmNGRlNTE3YTY5ZDhjMzNkYTVlMjqAAn1xAShVCHVzZXJuYW1l\ncQJYCQAAAGNoZXVuZ3NzaHEDVQ9fc2Vzc2lvbl9leHBpcnlxBEsAVRJfYXV0aF91c2VyX2JhY2tl\nbmRxBVUpZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmRxBlUNX2F1dGhf\ndXNlcl9pZHEHigEBdS4=\n','2015-12-18 04:36:11'),('12f554d8bbefc9a72694d23d35b75428','ZTJjNTY1Yzk2ZWFhY2Q0ODBiZDJmNGRlNTE3YTY5ZDhjMzNkYTVlMjqAAn1xAShVCHVzZXJuYW1l\ncQJYCQAAAGNoZXVuZ3NzaHEDVQ9fc2Vzc2lvbl9leHBpcnlxBEsAVRJfYXV0aF91c2VyX2JhY2tl\nbmRxBVUpZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmRxBlUNX2F1dGhf\ndXNlcl9pZHEHigEBdS4=\n','2015-12-18 04:37:15'),('89cd8384acd1360487ae741adb04adaf','ZTJjNTY1Yzk2ZWFhY2Q0ODBiZDJmNGRlNTE3YTY5ZDhjMzNkYTVlMjqAAn1xAShVCHVzZXJuYW1l\ncQJYCQAAAGNoZXVuZ3NzaHEDVQ9fc2Vzc2lvbl9leHBpcnlxBEsAVRJfYXV0aF91c2VyX2JhY2tl\nbmRxBVUpZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmRxBlUNX2F1dGhf\ndXNlcl9pZHEHigEBdS4=\n','2015-12-18 07:25:53'),('e8ad03e6559ec3701142eb0724aa306c','ZWUwZTllMGQ2NDkzYjcxMTVmNWRkZmI1MTg5YjVlOTE3NDQ4Y2NhNzqAAn1xAShVEl9hdXRoX3Vz\nZXJfYmFja2VuZHECVSlkamFuZ28uY29udHJpYi5hdXRoLmJhY2tlbmRzLk1vZGVsQmFja2VuZHED\nVQ1fYXV0aF91c2VyX2lkcQSKAQF1Lg==\n','2015-12-19 03:09:27'),('4f50ee2ff8c71addb67f217bab321cd5','ZTJjNTY1Yzk2ZWFhY2Q0ODBiZDJmNGRlNTE3YTY5ZDhjMzNkYTVlMjqAAn1xAShVCHVzZXJuYW1l\ncQJYCQAAAGNoZXVuZ3NzaHEDVQ9fc2Vzc2lvbl9leHBpcnlxBEsAVRJfYXV0aF91c2VyX2JhY2tl\nbmRxBVUpZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmRxBlUNX2F1dGhf\ndXNlcl9pZHEHigEBdS4=\n','2015-12-19 05:32:53'),('76095730f36d5b330ab44dceb5f6aabe','ZTJjNTY1Yzk2ZWFhY2Q0ODBiZDJmNGRlNTE3YTY5ZDhjMzNkYTVlMjqAAn1xAShVCHVzZXJuYW1l\ncQJYCQAAAGNoZXVuZ3NzaHEDVQ9fc2Vzc2lvbl9leHBpcnlxBEsAVRJfYXV0aF91c2VyX2JhY2tl\nbmRxBVUpZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmRxBlUNX2F1dGhf\ndXNlcl9pZHEHigEBdS4=\n','2015-12-19 11:12:46'),('3f926c73d478580e6975cfd23760ba3e','ZTJjNTY1Yzk2ZWFhY2Q0ODBiZDJmNGRlNTE3YTY5ZDhjMzNkYTVlMjqAAn1xAShVCHVzZXJuYW1l\ncQJYCQAAAGNoZXVuZ3NzaHEDVQ9fc2Vzc2lvbl9leHBpcnlxBEsAVRJfYXV0aF91c2VyX2JhY2tl\nbmRxBVUpZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmRxBlUNX2F1dGhf\ndXNlcl9pZHEHigEBdS4=\n','2015-12-19 11:23:57'),('dc3d14cc5dbdc3566f812685928068c0','ZTJjNTY1Yzk2ZWFhY2Q0ODBiZDJmNGRlNTE3YTY5ZDhjMzNkYTVlMjqAAn1xAShVCHVzZXJuYW1l\ncQJYCQAAAGNoZXVuZ3NzaHEDVQ9fc2Vzc2lvbl9leHBpcnlxBEsAVRJfYXV0aF91c2VyX2JhY2tl\nbmRxBVUpZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmRxBlUNX2F1dGhf\ndXNlcl9pZHEHigEBdS4=\n','2015-12-19 11:23:57'),('f2494ac6431cd19cc59745bc150a0537','YWVhYTgzZDMxMjljZjA5NmI5MzQyNDQ3YWRiNzI1YTcwODU3NjJkNTqAAn1xAShVCHVzZXJuYW1l\ncQJYCQAAAGNoZXVuZ3NzaHEDVQ1fYXV0aF91c2VyX2lkcQSKAQFVEl9hdXRoX3VzZXJfYmFja2Vu\nZHEFVSlkamFuZ28uY29udHJpYi5hdXRoLmJhY2tlbmRzLk1vZGVsQmFja2VuZHEGVQ9fc2Vzc2lv\nbl9leHBpcnlxB0sAdS4=\n','2015-12-19 11:43:30'),('4f571b1afa3a37efbf904e65f8d754b0','ZWUwZTllMGQ2NDkzYjcxMTVmNWRkZmI1MTg5YjVlOTE3NDQ4Y2NhNzqAAn1xAShVEl9hdXRoX3Vz\nZXJfYmFja2VuZHECVSlkamFuZ28uY29udHJpYi5hdXRoLmJhY2tlbmRzLk1vZGVsQmFja2VuZHED\nVQ1fYXV0aF91c2VyX2lkcQSKAQF1Lg==\n','2015-12-19 11:41:44'),('6fd6db373ad210a7cc96719bb80be4b6','YWVhYTgzZDMxMjljZjA5NmI5MzQyNDQ3YWRiNzI1YTcwODU3NjJkNTqAAn1xAShVCHVzZXJuYW1l\ncQJYCQAAAGNoZXVuZ3NzaHEDVQ1fYXV0aF91c2VyX2lkcQSKAQFVEl9hdXRoX3VzZXJfYmFja2Vu\nZHEFVSlkamFuZ28uY29udHJpYi5hdXRoLmJhY2tlbmRzLk1vZGVsQmFja2VuZHEGVQ9fc2Vzc2lv\nbl9leHBpcnlxB0sAdS4=\n','2015-12-19 14:49:45'),('2b6b2229ed31e4f61c33b1bde36a435a','ZWUwZTllMGQ2NDkzYjcxMTVmNWRkZmI1MTg5YjVlOTE3NDQ4Y2NhNzqAAn1xAShVEl9hdXRoX3Vz\nZXJfYmFja2VuZHECVSlkamFuZ28uY29udHJpYi5hdXRoLmJhY2tlbmRzLk1vZGVsQmFja2VuZHED\nVQ1fYXV0aF91c2VyX2lkcQSKAQF1Lg==\n','2015-12-20 01:45:17');
/*!40000 ALTER TABLE `django_session` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2015-12-06  9:45:56
