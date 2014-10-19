#!/usr/bin/env python
#encoding:utf-8
####################################################################################################
## 
## Author: wishinlife
## QQ: 57956720
## E-Mail: wishinlife@gmail.com
## Web Home: http://syncyhome.duapp.com, http://hi.baidu.com/wishinlife
## Update date: 2014-10-18
## VERSION: 1.0.15
## Required packages: kmod-nls-utf8,libopenssl,libcurl,python,python-mini,python-curl
## 
####################################################################################################

import os
import sys
import hashlib
import time
import re
import struct
#import binascii
import zlib
#import fileinput
import pycurl
from urllib import quote_plus

# set config_file and pidfile for your config storage path.
__CONFIG_FILE__ = '/opt/etc/syncy'
__PIDFILE__ = '/var/run/syncy.pid'

#  Don't modify the following.
__VERSION__ = '1.0.15'
class SyncY:
	def __init__(self,argv = sys.argv[1:]):
		self._oldSTDERR = None
		self._oldSTDOUT = None
		self._argv = argv
		if len(self._argv) == 0 or self._argv[0] == 'compress' or self._argv[0] == 'convert':
			if os.path.exists(__PIDFILE__):
				pidh = open(__PIDFILE__, 'r')
				mypid = pidh.read()
				pidh.close()
				try:
					os.kill(int(mypid), 0)
				except os.error:
					pass
				else:
					print("SyncY is running!")
					sys.exit(0)
			pidh = open(__PIDFILE__, 'w')
			pidh.write(str(os.getpid()))
			pidh.close()
		if not(os.path.isfile(__CONFIG_FILE__)):
			sys.stderr.write('%s ERROR: Config file "%s" does not exist.\n' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()),__CONFIG_FILE__))
			sys.exit(1)
		self._pcsroot = '/apps/SyncY'
		self._synccount = 0
		self._failcount = 0
		self._errorcount = 0
		self._response_str = None
		self._sydb = None
		self._sydblen = None
		self._syncData = None
		self._basedirlen = None
		self._syncydb = None
		self._syncydbtmp = None
		self._config = {
			'syncyerrlog'	: '', 
			'syncylog'		: '', 
			'blocksize'		: 10, 
			'ondup'			: 'rename', 
			'datacache'		: 'on', 
			'slicedownload'	: 'on',
			'excludefiles'	: '',
			'listnumber'	: 100, 
			'retrytimes'	: 3,
			'retrydelay'	: 3,
			'maxsendspeed'	: 0,
			'maxrecvspeed'	: 0,
			'syncperiod'	: '0-24',
			'syncinterval'	: 3600,
			}
		self._syncytoken = {'synctotal': 0}
		self._syncpath = {}
		sycfg = open(__CONFIG_FILE__,'r')
		line = sycfg.readline()
		section = ''
		while line:
			if re.findall(r'^\s*#',line) or re.findall(r'^\s*$',line):
				line = sycfg.readline()
				continue
			line = re.sub(r'#[^\']*$','',line)
			m = re.findall(r'\s*config\s+([^\s]+).*', line)
			if m:
				section = m[0].strip('\'')
				if section == 'syncpath':
					self._syncpath[str(len(self._syncpath))]={}
				line = sycfg.readline()
				continue
			m = re.findall(r'\s*option\s+([^\s]+)\s+\'([^\']*)\'',line)
			if m:
				if section == 'syncy':
					self._config[m[0][0].strip('\'')] = m[0][1]
				elif section == 'syncytoken':
					self._syncytoken[m[0][0].strip('\'')] = m[0][1]
				elif section == 'syncpath':
					self._syncpath[str(len(self._syncpath) - 1)][m[0][0].strip('\'')] = m[0][1]
			line = sycfg.readline()
		sycfg.close()
		self._config['retrytimes'] = int(self._config['retrytimes'])
		self._config['retrydelay'] = int(self._config['retrydelay'])
		self._config['maxsendspeed'] = int(self._config['maxsendspeed'])
		self._config['maxrecvspeed'] = int(self._config['maxrecvspeed'])
		if not(self._syncytoken.has_key('refresh_token')) or self._syncytoken['refresh_token'] == '' or (len(self._argv) !=0 and self._argv[0] in ["sybind","cpbind"]):
			if ((not(self._syncytoken.has_key('device_code')) or self._syncytoken['device_code'] == '') and len(self._argv) == 0) or (len(self._argv) != 0 and self._argv[0] == "sybind"):
				http_code = self.__curl_request('https://syncyhome.duapp.com/syserver','method=bind_device&scope=basic,netdisk','POST','normal')
				if http_code != 200:
					sys.stderr.write("%s ERROR: Get device code failed, %s.\n" % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()),self._response_str))
					sys.exit(1)
				m = re.findall(r'.*\"device_code\":\"([0-9a-z]+)\".*',self._response_str)
				if m:
					device_code = m[0]
					m = re.findall(r'.*\"user_code\":\"([0-9a-z]+)\".*',self._response_str)
					user_code = m[0]
				else:
					print(time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()) + " Can't get device code.")
					sys.exit(1)
				if len(self._argv) != 0 and self._argv[0] == "sybind":
					sybind = open("/tmp/syncy.bind", 'w')
					sybind.write('{"user_code":"%s","device_code":"%s","time":%d}' % (user_code, device_code, int(time.time())))
					sybind.close()
					sys.exit(0)
				self._syncytoken['device_code'] = device_code
				print("Device binding Guide:")
				print("     1. Open web browser to visit:\"https://openapi.baidu.com/device\" and input user code to binding your baidu account.")
				print(" ")
				print("     2. User code:\033[31m %s\033[0m" % user_code)
				print("     (The user code is available for 30 minutes.)")
				print(" ")
				raw_input('     3. After granting access to the application, come back here and press [Enter] to continue.')
				print(" ")
			if len(self._argv) != 0 and self._argv[0] == "cpbind":
				sybind = open("/tmp/syncy.bind", 'r')
				bindinfo = sybind.read()
				sybind.close()
				m = re.findall(r'.*\"device_code\":\"([0-9a-z]+)\".*',bindinfo)
				os.remove("/tmp/syncy.bind")
				if m:
					self._syncytoken['device_code'] = m[0]
					m = re.findall(r'.*\"time\":([0-9]+).*',bindinfo)
					if int(time.time()) - int(m[0]) >= 1800:
						sys.exit(1)
				else:
					sys.exit(1)
			http_code = self.__curl_request('https://syncyhome.duapp.com/syserver','method=get_device_token&code=%s' % (self._syncytoken['device_code']),'POST','normal')
			if http_code != 200 or self._response_str == '':
				sys.stderr.write("%s ERROR: Get device token failed, error message: %s.\n" % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()),self._response_str))
				sys.exit(1)
			m = re.findall(r'.*\"refresh_token\":\"([^"]+)\".*',self._response_str)
			if m:
				self._syncytoken['refresh_token'] = m[0]
				m = re.findall(r'.*\"access_token\":\"([^"]+)\".*',self._response_str)
				self._syncytoken['access_token'] = m[0]
				m = re.findall(r'.*\"expires_in\":([0-9]+).*',self._response_str)
				self._syncytoken['expires_in'] = m[0]
				self._syncytoken['refresh_date'] = int(time.time())
				self._syncytoken['compress_date'] = int(time.time())
				self.__save_config()
				if len(self._argv) != 0 and self._argv[0] == "cpbind":
					sys.exit(0)
				print("%s Get device token success.\n" % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())))
			else:
				sys.stderr.write("%s ERROR: Get device token failed, error message: %s.\n" % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()),self._response_str))
				sys.exit(1)
		if self._config['syncyerrlog'] != '' and os.path.exists(os.path.dirname(self._config['syncyerrlog'])):
			if os.path.exists(self._config['syncyerrlog']) and os.path.isdir(self._config['syncyerrlog']):
				self._config['syncyerrlog'] += 'syncyerr.log'
				self.__save_config()
			self._oldSTDERR = sys.stderr
			sys.stderr = open(self._config['syncyerrlog'],'a',0)
		if self._config['syncylog'] != '' and os.path.exists(os.path.dirname(self._config['syncylog'])):
			if os.path.exists(self._config['syncylog']) and os.path.isdir(self._config['syncylog']):
				self._config['syncylog'] += 'syncy.log'
				self.__save_config()
			print('%s Running log output to log file:%s.' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()),self._config['syncylog']))
			self._oldSTDOUT = sys.stdout
			sys.stdout = open(self._config['syncylog'],'a',0)
		self._config['blocksize'] = int(self._config['blocksize'])
		self._config['listnumber'] = int(self._config['listnumber'])
		self._config['syncinterval'] = int(self._config['syncinterval'])
		self._syncytoken['refresh_date'] = int(self._syncytoken['refresh_date'])
		self._syncytoken['expires_in'] = int(self._syncytoken['expires_in'])
		self._syncytoken['compress_date'] = int(self._syncytoken['compress_date'])
		self._syncytoken['synctotal'] = int(self._syncytoken['synctotal'])
		if self._config['blocksize'] < 1:
			self._config['blocksize'] = 10
			print('%s WARNING: "blocksize" must great than or equal to 1(M), set to default 10(M).' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())))
		if self._config['ondup'] != 'overwrite' and self._config['ondup'] != 'rename':
			self._config['ondup'] = 'rename'
			print('%s WARNING: ondup is invalid, set to default(overwrite).' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())))
		if self._config['datacache'] != 'on' and self._config['datacache'] != 'off':
			self._config['datacache'] = 'on'
			print('%s WARNING: "datacache" is invalid, set to default(on).' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())))
		if self._config['slicedownload'] != 'on' and self._config['slicedownload'] != 'off':
			self._config['slicedownload'] = 'on'
			print('%s WARNING: "slicedownload" is invalid, set to default(on).' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())))
		if self._config['retrytimes'] < 0:
			self._config['retrytimes'] = 3
			print('%s WARNING: "retrytimes" is invalid, set to default(3 times).' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())))
		if self._config['retrydelay'] < 0:
			self._config['retrydelay'] = 3
			print('%s WARNING: "retrydelay" is invalid, set to default(3 second).' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())))
		if self._config['listnumber'] < 1:
			self._config['listnumber'] = 100
			print('%s WARNING: "listnumber" must great than or equal to 1, set to default 100.' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())))
		if self._config['syncinterval'] < 1:
			self._config['syncinterval'] = 3600
			print('%s WARNING: "syncinterval" must great than or equal to 1, set to default 3600.' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())))
		if self._config['maxsendspeed'] < 0:
			self._config['maxsendspeed'] = 0
			print('%s WARNING: "maxsendspeed" must great than or equal to 0, set to default 0.' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())))
		if self._config['maxrecvspeed'] < 0:
			self._config['maxrecvspeed'] = 0
			print('%s WARNING: "maxrecvspeed" must great than or equal to 0, set to default 100.' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())))
		if (self._syncytoken['refresh_date'] + self._syncytoken['expires_in'] - 864000) < int(time.time()):
			self.__check_expires()
		exfiles = self._config['excludefiles']
		exfiles = exfiles.replace(".","\.").replace("*",".*").replace("?",".?")
		self._excludefiles = exfiles.split(';')
		for i in xrange(len(self._excludefiles)):
			self._excludefiles[i] = re.compile(eval('r"^' + self._excludefiles[i] + '$"'))
		self._excludefiles.append(re.compile(r'^.*\.tmp\.syy$'))
		self._excludefiles.append(re.compile(r'^.*\.part\.syy$'))
		self._re = {
			'path'	: re.compile(r'.*\"path\":\"([^"]+)\",.*'),
			'size'	: re.compile(r'.*\"size\":([0-9]+),.*'),
			'md5'	: re.compile(r'.*\"md5\":\"([^"]+)\".*'),
			'isdir'	: re.compile(r'.*\"isdir\":([0-1]).*'),
			'mtime'	: re.compile(r'.*\"mtime\":([0-9]+).*'),
			'error_code'	: re.compile(r'.*\"error_code\":([0-9]+),.*'),
			'newname'	: re.compile(r'^(.*)(\.[^.]+)$'),
			'getlist'	: re.compile(r'^\{\"list\":\[(\{.*\}|)\],\"request_id\".*'),
			'listrep'	: re.compile(r'},\{\"fs_id'),
			'pcspath'	: re.compile(r'^[\s\.\r\n].*|.*[/<>\\|\*\?:\"].*|.*[\s\.\r\n]$')
			}
	def __del__(self):
		if None != self._oldSTDERR:
			sys.stderr.close()
			sys.stderr = self._oldSTDERR
		if None != self._oldSTDOUT:
			sys.stdout.close()
			sys.stdout = self._oldSTDOUT
		if os.path.exists(__PIDFILE__):
			pidh = open(__PIDFILE__, 'r')
			lckpid = pidh.read()
			pidh.close()
			if os.getpid() == int(lckpid):
				os.remove(__PIDFILE__)
	def __init_syncdata(self):
		self._syncData = {}
		if os.path.exists(self._syncydb):
			sydb = open(self._syncydb, 'rb')
			dataline = sydb.read(40)
			while dataline:
				self._syncData[dataline[24:]] = dataline[0:24]
				dataline = sydb.read(40)
			sydb.close()
	def __check_expires(self):
		http_code = self.__curl_request('https://syncyhome.duapp.com/syserver?method=get_last_version&edition=python&ver=%s' % __VERSION__,'','POST','normal')
		(lastVer,smessage) = self._response_str.strip('\n').split('#')
		if http_code == 200 and lastVer != __VERSION__:
			sys.stderr.write('%s %s\n' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), smessage))
			print('%s %s' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), smessage))
		http_code = self.__curl_request('https://syncyhome.duapp.com/syserver','method=refresh_access_token&refresh_token=%s' % (self._syncytoken['refresh_token']),'POST','normal')
		if http_code != 200:
			sys.stderr.write('%s ERROR: Refresh access token failed: %s.\n' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()),self._response_str))
			return 1
		m = re.findall(r'.*\"refresh_token\":\"([^"]+)\".*',self._response_str)
		if m:
			self._syncytoken['refresh_token'] = m[0]
			m = re.findall(r'.*\"access_token\":\"([^"]+)\".*',self._response_str)
			self._syncytoken['access_token'] = m[0]
			m = re.findall(r'.*\"expires_in\":([0-9]+).*',self._response_str)
			self._syncytoken['expires_in'] = int(m[0])
			self._syncytoken['refresh_date'] = int(time.time())
			self.__save_config()
			print(time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()) + ' Refresh access token success.')
			return 0
		else:
			sys.stderr.write('%s ERROR: Refresh access token failed: %s.\n' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()),self._response_str))
			return 1
	def __save_config(self):
		sycfg = open(__CONFIG_FILE__ + '.sybak', 'w')
		sycfg.write("\nconfig syncy\n")
		for key,value in self._config.items():
			sycfg.write("\toption " + key + " '" + str(value) + "'\n")
		sycfg.write("\nconfig syncytoken\n")
		for key,value in self._syncytoken.items():
			sycfg.write("\toption " + key + " '" + str(value) + "'\n")
		for i in range(len(self._syncpath)):
			sycfg.write("\nconfig syncpath\n")
			for key,value in self._syncpath[str(i)].items():
				sycfg.write("\toption " + key + " '" + str(value) + "'\n")
		sycfg.close()
		pmeta = os.stat(os.path.dirname(__CONFIG_FILE__))
		os.rename(__CONFIG_FILE__ + '.sybak', __CONFIG_FILE__)
		os.lchown(__CONFIG_FILE__, pmeta.st_uid, pmeta.st_gid)
	def __save_data(self,rmd5,fmtime,fsize,fmd5):
		sydb = open(self._syncydb,'ab')
		rmd5 = rmd5.decode('hex')
		fmtime = struct.pack('>I',fmtime)
		fsize = struct.pack('>I', fsize % 4294967296)
		sydb.write(rmd5 + fmtime + fsize + fmd5)
		sydb.close()
	def __write_data(self,rsp):
		self._response_str += rsp
		return len(rsp)
	@staticmethod
	def __write_header(rsp):
		return len(rsp)
	def __curl_request(self,URL,rData,method,rType,fnname = ''):
		curl = pycurl.Curl()
		curl.setopt(pycurl.URL, URL)
		curl.setopt(pycurl.SSL_VERIFYPEER, 0)
		curl.setopt(pycurl.SSL_VERIFYHOST, 2)
		curl.setopt(pycurl.FOLLOWLOCATION, 1)
		curl.setopt(pycurl.CONNECTTIMEOUT, 15)
		curl.setopt(pycurl.LOW_SPEED_LIMIT, 1)
		curl.setopt(pycurl.LOW_SPEED_TIME, 60)
		curl.setopt(pycurl.USERAGENT, '')
		if self._config['maxsendspeed'] != 0:
			curl.setopt(pycurl.MAX_SEND_SPEED_LARGE, self._config['maxsendspeed'])
		if self._config['maxrecvspeed'] != 0:
			curl.setopt(pycurl.MAX_RECV_SPEED_LARGE, self._config['maxrecvspeed'])
		curl.setopt(pycurl.HEADER, 0)
		retrycnt = 0
		while retrycnt <= self._config['retrytimes']:
			try:
				self._response_str = ''
				if rType == 'upfile':
					curl.setopt(pycurl.UPLOAD,1)
					ulFile = open(fnname,'rb')
					if rData != '':
						(foffset,flen) = rData.split(':')
						foffset = int(foffset)
						flen = int(flen)
						ulFile.seek(foffset)
					else:
						flen = os.stat(fnname).st_size
					curl.setopt(pycurl.READDATA, ulFile)
					curl.setopt(pycurl.INFILESIZE, flen)
					curl.setopt(pycurl.WRITEFUNCTION, self.__write_data)
					curl.perform()
					ulFile.close()
				elif rType == 'downfile':
					curl.setopt(pycurl.OPT_FILETIME,1)
					if os.path.exists(fnname):
						drange = str(os.stat(fnname).st_size) + '-'
						curl.setopt(pycurl.RANGE, drange)
					dlFile = open(fnname, 'ab')
					curl.setopt(pycurl.WRITEDATA, dlFile)
					curl.perform()
					dlFile.close()
					filemtime = curl.getinfo(pycurl.INFO_FILETIME)
					os.utime(fnname, (filemtime, filemtime))
					pmeta = os.stat(os.path.dirname(fnname))
					os.lchown(fnname,pmeta.st_uid,pmeta.st_gid)
				else:
					curl.setopt(pycurl.CUSTOMREQUEST, method)
					curl.setopt(pycurl.POSTFIELDS, rData)
					curl.setopt(pycurl.WRITEFUNCTION, self.__write_data)
					curl.perform()
				self._response_str = self._response_str.strip('\n')
				http_code = curl.getinfo(pycurl.HTTP_CODE)
				if http_code < 400 or retrycnt == self._config['retrytimes']:
					return http_code
				else:
					retrycnt += 1
					print('%s WARNING: Request failed, wait %d seconds and try again(%d). Http(%d): %s.' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), self._config['retrydelay'], retrycnt, http_code, self._response_str))
					time.sleep(self._config['retrydelay'])
			except pycurl.error, error:
				errno, errstr = error
				if retrycnt == self._config['retrytimes']:
					return errno
				else:
					retrycnt += 1
					print('%s WARNING: Request failed, wait %d seconds and try again(%d). Curl(%d): %s.' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), self._config['retrydelay'], retrycnt, errno, errstr))
	def __curl_request_sd(self,URL,method,fnname,filelength):
		curl = pycurl.Curl()
		curl.setopt(pycurl.URL, URL)
		curl.setopt(pycurl.SSL_VERIFYPEER, 0)
		curl.setopt(pycurl.SSL_VERIFYHOST, 2)
		curl.setopt(pycurl.FOLLOWLOCATION, 1)
		curl.setopt(pycurl.CONNECTTIMEOUT, 15)
		curl.setopt(pycurl.LOW_SPEED_LIMIT, 1)
		curl.setopt(pycurl.LOW_SPEED_TIME, 60)
		curl.setopt(pycurl.USERAGENT, '')
		if self._config['maxsendspeed'] != 0:
			curl.setopt(pycurl.MAX_SEND_SPEED_LARGE, self._config['maxsendspeed'])
		if self._config['maxrecvspeed'] != 0:
			curl.setopt(pycurl.MAX_RECV_SPEED_LARGE, self._config['maxrecvspeed'])
		curl.setopt(pycurl.HEADER, 0)
		retrycnt = 0
		srange = 0
		if os.path.exists(fnname):
			srange = os.stat(fnname).st_size
		self._response_str = ''
		while retrycnt <= self._config['retrytimes']:
			try:
				curl.setopt(pycurl.OPT_FILETIME,1)
				if filelength < srange + (self._config['blocksize'] + 1) * 1048576:
					curl.setopt(pycurl.RANGE, str(srange) + '-' + str(filelength - 1))
				else:
					curl.setopt(pycurl.RANGE, str(srange) + '-' + str(srange + self._config['blocksize'] * 1048576 - 1))
				dlFile = open(fnname + '.part.syy', 'wb')
				curl.setopt(pycurl.WRITEDATA, dlFile)
				curl.perform()
				dlFile.close()
				http_code = curl.getinfo(pycurl.HTTP_CODE)
				if http_code == 200 or http_code == 206:	
					with open(fnname, "ab") as dlfh:  
						with open(fnname + '.part.syy', "rb") as ptfh:
							fbuffer = ptfh.read(8192)
							while fbuffer:
								dlfh.write(fbuffer)
								fbuffer = ptfh.read(8192)
							ptfh.close()
						dlfh.close()
					os.remove(fnname + '.part.syy')
					srange = os.stat(fnname).st_size
					if srange == filelength:
						filemtime = curl.getinfo(pycurl.INFO_FILETIME)
						os.utime(fnname, (filemtime, filemtime))
						pmeta = os.stat(os.path.dirname(fnname))
						os.lchown(fnname,pmeta.st_uid,pmeta.st_gid)
						return http_code
				elif http_code < 400 or retrycnt == self._config['retrytimes']:
					return http_code
				else:
					retrycnt += 1
					print('%s WARNING: Request failed, wait %d seconds and try again(%d). Http(%d).' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), self._config['retrydelay'], retrycnt, http_code))
					time.sleep(self._config['retrydelay'])
			except pycurl.error, error:
				errno, errstr = error
				if retrycnt == self._config['retrytimes']:
					return errno
				else:
					retrycnt += 1
					print('%s WARNING: Request failed, wait %d seconds and try again(%d). Curl(%d): %s.' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), self._config['retrydelay'], retrycnt, errno, errstr))
	@staticmethod
	def __md5sum(fname):  
		with open(fname, "rb") as fh:  
			m = hashlib.md5()  
			fbuffer = fh.read(8192)
			while fbuffer:  
				m.update(fbuffer)
				fbuffer = fh.read(8192)
			fh.close()
			cmd5 = m.hexdigest()
		return cmd5
	@staticmethod
	def __rapid_checkcode(fname):  
		with open(fname, "rb") as fh:  
			m = hashlib.md5()  
			fbuffer = fh.read(8192)
			crc = 0
			while fbuffer:  
				m.update(fbuffer)
				crc = zlib.crc32(fbuffer, crc) & 0xffffffff
				fbuffer = fh.read(8192)
			cmd5 = m.hexdigest()
			m = hashlib.md5()
			fh.seek(0)
			for i in range(32):
				fbuffer = fh.read(8192)
				m.update(fbuffer)
			fh.close()
		return '%x' % crc,cmd5,m.hexdigest()
	@staticmethod
	def __catpath(*names):
		fullpath = '/'.join(names)
		fullpath = re.sub(r'/+','/',fullpath)
		fullpath = re.sub(r'/$','',fullpath)
		return fullpath
	def __get_pcs_quota(self):
		http_code = self.__curl_request('https://pcs.baidu.com/rest/2.0/pcs/quota?method=info&access_token=%s' % (self._syncytoken['access_token']),'','GET','normal')
		if http_code != 200: 
			sys.stderr.write('%s ERROR: Get pcs quota failed(error code:%d),%s.\n' %(time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), http_code, self._response_str))
			return 1
		m = re.findall(r'.*\"quota\":([0-9]+).*',self._response_str)
		if m:
			quota =int(m[0])/1024/1024/1024
			m = re.findall(r'.*\"used\":([0-9]+).*',self._response_str)
			used = int(m[0])/1024/1024/1024
			print('%s PCS quota is %dG,used %dG.' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), quota, used))
			return 0
		else:
			sys.stderr.write('%s ERROR: Get pcs quota failed,%s.\n' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), self._response_str))
			return 1
	def __get_pcs_filemeta(self,filepath):
		uripath = quote_plus(filepath)
		http_code = self.__curl_request('https://pcs.baidu.com/rest/2.0/pcs/file?method=meta&access_token=%s&path=%s' % (self._syncytoken['access_token'], uripath),'','GET','normal')
		if http_code != 200:
			sys.stderr.write('%s ERROR: Get file meta failed(error code:%d): %s, %s.\n' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), http_code, filepath, self._response_str))
			return 1
		return 0
	def __get_pcs_filelist(self,pcspath,startindex,endindex):
		uripath = quote_plus(pcspath)
		http_code = self.__curl_request('https://pcs.baidu.com/rest/2.0/pcs/file?method=list&access_token=%s&path=%s&limit=%d-%d&by=name&order=asc' % (self._syncytoken['access_token'], uripath, startindex, endindex),'','GET','normal')
		if http_code != 200:
			m = self._re['error_code'].findall(self._response_str)
			if m and int(m[0]) == 31066:
				return 31066,[]
			else:
				sys.stderr.write('%s ERROR: Get file list failed(error code:%d): %s, %s.\n' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), http_code, pcspath, self._response_str))
				self._errorcount += 1
				return 1,[]
		self._response_str = self._re['getlist'].findall(self._response_str)[0]
		if len(self._response_str) == 0:
			return 0,[]
		self._response_str = self._response_str.replace('\/','/').replace('"','\\"')
		self._response_str = eval('u"' + self._response_str + '"').encode('utf8')
		self._response_str = self._re['listrep'].sub('}\n{"fs_id', self._response_str)
		fileList = self._response_str.split('\n')
		self._response_str = ''
		return 0,fileList
	def __upload_file_nosync(self,filepath,pcspath):
		uripath = quote_plus(pcspath)
		http_code = self.__curl_request('https://c.pcs.baidu.com/rest/2.0/pcs/file?method=upload&access_token=%s&path=%s&ondup=newcopy' % (self._syncytoken['access_token'], uripath),'','POST','upfile',filepath)
		if http_code != 200:
			sys.stderr.write('%s ERROR: Upload file to pcs failed(error code:%d): %s, %s.\n' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), http_code, filepath, self._response_str))
			return 1
		print('%s Upload file "%s" completed.' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), filepath))
		return 0
	def __upload_file(self,filepath,fmtime,fsize,pcspath,fmd5,ondup,lcmd5 = ''):
		uripath = quote_plus(pcspath)
		http_code = self.__curl_request('https://c.pcs.baidu.com/rest/2.0/pcs/file?method=upload&access_token=%s&path=%s&ondup=%s' % (self._syncytoken['access_token'], uripath, ondup),'','POST','upfile',filepath)
		if http_code != 200:
			sys.stderr.write('%s ERROR: Upload file to pcs failed(error code:%d): %s, %s.\n' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), http_code, filepath, self._response_str))
			return 1
		m = self._re['size'].findall(self._response_str)
		if m and int(m[0]) == fsize:
			m = self._re['md5'].findall(self._response_str)
			rmd5 = m[0]
		else:
			sys.stderr.write('%s ERROR: Upload File failed, remote file error : %s, %s.\n' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), filepath, self._response_str))
			self.__rm_pcsfile(pcspath,'s')
			return 1
		self.__save_data(rmd5,fmtime,fsize,fmd5)
		print('%s Upload file "%s" completed.' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), filepath))
		return 0
	def __rapid_uploadfile(self,filepath,fmtime,fsize,pcspath,fmd5,ondup):
		if fsize <= 262144:
			return self.__upload_file(filepath,fmtime,fsize,pcspath,fmd5,ondup)
		crc, contentmd5, slicemd5 = self.__rapid_checkcode(filepath)
		uripath = quote_plus(pcspath)
		http_code = self.__curl_request('https://pcs.baidu.com/rest/2.0/pcs/file?method=rapidupload&access_token=%s&path=%s&content-length=%d&content-md5=%s&slice-md5=%s&content-crc32=%s&ondup=%s' % (self._syncytoken['access_token'], uripath, fsize, contentmd5, slicemd5, crc, ondup),'','POST','normal')
		if http_code != 200:
			m = self._re['error_code'].findall(self._response_str)
			if m and int(m[0]) == 31079:
				print('%s File md5 not found, upload the whole file "%s".' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), filepath))
				print('%s httpcode:%s , md5:%s, CRC32: %s, %s.' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), http_code, contentmd5, crc, self._response_str))
				if fsize <= self._config['blocksize'] * 1048576 + 1048576:
					return self.__upload_file(filepath,fmtime,fsize,pcspath,fmd5,ondup,contentmd5)
				else:
					return self.__slice_uploadfile(filepath,fmtime,fsize,pcspath,fmd5,ondup,contentmd5)
			else:
				sys.stderr.write('%s ERROR: Rapid upload file failed(error code:%d): %s, %s.\n' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), http_code, filepath, self._response_str))
				return 1
		else:
			m = self._re['size'].findall(self._response_str)
			if m and int(m[0]) == fsize:
				m = self._re['md5'].findall(self._response_str)
				rmd5 = m[0]
			else:
				sys.stderr.write('%s ERROR: File is rapiduploaded,but can not get remote file size: %s, %s.\n' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), filepath, self._response_str))
				return 1
			self.__save_data(rmd5,fmtime,fsize,fmd5)
			print('%s Rapid upload file "%s" completed.' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), filepath))
			return 0
	def __slice_uploadfile(self,filepath,fmtime,fsize,pcspath,fmd5,ondup,lcmd5 = ''):
		if fsize <= (self._config['blocksize'] + 1) * 1048576:
			return self.__upload_file(filepath,fmtime,fsize,pcspath,fmd5,ondup)
		elif fsize > self._config['blocksize'] * 1073741824:
			sys.stderr.write('%s ERROR: File "%s" size exceeds the setting, maxsize = blocksize * 1024M.\n' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), filepath))
			return 1
		startblk = 0
		upblkcount = self._config['blocksize']
		param = 'param={"block_list":['
		if os.path.exists(filepath + '.tmp.syy'):
			ulfn = open(filepath + '.tmp.syy','r')
			upinfo = ulfn.readlines()
			ulfn.close()
			if upinfo[0].strip('\n') != 'upload %d %d' % (fmtime, fsize):
				ulfn = open(filepath + '.tmp.syy','w')
				ulfn.write('upload %d %d\n' % (fmtime, fsize))
				ulfn.close()
				print('%s Local file:"%s" is modified, reupload the whole file.' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), filepath))
			else:
				for i in range(1, len(upinfo)):
					blmd5,bllen = upinfo[i].strip('\n').split(' ')[1:]
					if blmd5 == '':
						continue
					if startblk == 0:
						param += '"' + blmd5 + '"'
					else:
						param += ',"' + blmd5 + '"'
					startblk +=  int(bllen)
				print('%s Resuming slice upload file "%s".' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), filepath))
		else:
			ulfn = open(filepath + '.tmp.syy','w')
			ulfn.write('upload %d %d\n' % (fmtime, fsize))
			ulfn.close()
		while startblk * 1048576 < fsize:
			if fsize > (startblk + self._config['blocksize'] + 1) * 1048576:
				upBlockLen = upblkcount * 1048576
			else:
				upBlockLen = fsize - startblk * 1048576
				upblkcount = self._config['blocksize'] + 1
			sliceRange = str(startblk * 1048576) + ':' + str(upBlockLen)
			http_code = self.__curl_request('https://c.pcs.baidu.com/rest/2.0/pcs/file?method=upload&access_token=%s&type=tmpfile' % (self._syncytoken['access_token']),sliceRange,'POST','upfile',filepath)
			if http_code != 200:
				sys.stderr.write('%s ERROR: Slice upload file failed(error code:%d): %s, %s.\n' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), http_code, filepath, self._response_str))
				return 1
			blockmd5 = self._re['md5'].findall(self._response_str)[0]
			ulfn = open(filepath + ".tmp.syy",'a')
			ulfn.write('md5-%d %s %d\n' % (startblk, blockmd5, upblkcount))
			ulfn.close()
			if startblk == 0:
				param += '"' + blockmd5 + '"'
			else:
				param += ',"' + blockmd5 + '"'
			startblk += upblkcount
		param += ']}'
		uripath = quote_plus(pcspath)
		http_code = self.__curl_request('https://pcs.baidu.com/rest/2.0/pcs/file?method=createsuperfile&access_token=%s&path=%s&ondup=%s' % (self._syncytoken['access_token'], uripath, ondup),param,'POST','normal')
		if http_code != 200:
			sys.stderr.write('%s ERROR: Create superfile failed(error code:%d): %s, %s.\n' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), http_code, filepath, self._response_str))
			return 1
		os.remove(filepath + '.tmp.syy')
		m = self._re['size'].findall(self._response_str)
		if m and int(m[0]) == fsize:
			rmd5 = self._re['md5'].findall(self._response_str)[0]
		else:
			sys.stderr.write('%s ERROR: Slice upload file failed: %s, %s.\n' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), filepath, self._response_str))
			self.__rm_pcsfile(pcspath,'s')
			return 1
		self.__save_data(rmd5,fmtime,fsize,fmd5)
		print('%s Slice upload file "%s" completed.' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), filepath))
		return 0
	def __download_file(self,pcspath,rmd5,rsize,filepath,fmd5):
		if os.path.exists(filepath + '.tmp.syy'):
			dlfn = open(filepath + '.tmp.syy', 'r')
			dlinfo = dlfn.readlines()
			dlfn.close()
			if dlinfo[0].strip('\n') != 'download %s %d' % (rmd5,rsize):
				dlfn = open(filepath + '.tmp.syy','w')
				dlfn.write('download %s %d\n' % (rmd5 , rsize))
				dlfn.close()
				print('%s Remote file:"%s" is modified, redownload the whole file.' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), pcspath))
				os.remove(filepath)
			else:
				print('%s Resuming download file "%s".' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), pcspath))
		else:
			dlfn = open(filepath + '.tmp.syy','w')
			dlfn.write('download %s %d\n' % (rmd5, rsize))
			dlfn.close()
		uripath = quote_plus(pcspath)
		if self._config['slicedownload'] == 'off':
			http_code = self.__curl_request('https://d.pcs.baidu.com/rest/2.0/pcs/file?method=download&access_token=%s&path=%s' % (self._syncytoken['access_token'], uripath),'','GET','downfile',filepath)
		else:
			http_code = self.__curl_request_sd('https://d.pcs.baidu.com/rest/2.0/pcs/file?method=download&access_token=%s&path=%s' % (self._syncytoken['access_token'], uripath), 'GET', filepath, rsize)
		if http_code != 200 and http_code != 206:
			sys.stderr.write('%s ERROR: Download file failed(error code:%d): "%s".\n' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), http_code, pcspath))
			return 1
		fmeta = os.stat(filepath)
		os.remove(filepath + '.tmp.syy')
		if fmeta.st_size != rsize:
			sys.stderr.write('%s ERROR: Download file failed: "%s", downloaded file size not equal to remote file size.\n' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), pcspath))
			os.remove(filepath)
			return 1
		self.__save_data(rmd5,int(fmeta.st_mtime),fmeta.st_size,fmd5)
		print('%s Download file "%s" completed.' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), pcspath))
		return 0
	def __rm_pcsfile(self,pcspath,slient = ''):
		uripath = quote_plus(pcspath)
		http_code = self.__curl_request('https://pcs.baidu.com/rest/2.0/pcs/file?method=delete&access_token=%s&path=%s' % (self._syncytoken['access_token'], uripath),'','POST','normal')
		if http_code !=200:
			sys.stderr.write('%s ERROR: Delete remote file failed(error code:%d): %s, %s.\n' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), http_code, pcspath, self._response_str))
			return 1
		elif slient == '':
			print('%s Delete remote file or directory "%s" completed.' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), pcspath))
		return 0
	def __mv_pcsfile(self,oldpcspath,newpcspath):
		uripaths = quote_plus(oldpcspath)
		uripathd = quote_plus(newpcspath)
		http_code = self.__curl_request('https://pcs.baidu.com/rest/2.0/pcs/file?method=move&access_token=%s&from=%s&to=%s' % (self._syncytoken['access_token'], uripaths, uripathd),'','POST','normal')
		if http_code != 200:
			sys.stderr.write('%s ERROR: Move remote file or directory "%s" to "%s" failed(error code:%d): %s.\n' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), oldpcspath, newpcspath, http_code, self._response_str))
			return 1
		print('%s Move remote file or directory "%s" to "%s" completed.' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), oldpcspath, newpcspath))
		return 0
	def __cp_pcsfile(self,srcpcspath,destpcspath):
		uripaths = quote_plus(srcpcspath)
		uripathd = quote_plus(destpcspath)
		http_code = self.__curl_request('https://pcs.baidu.com/rest/2.0/pcs/file?method=copy&access_token=%s&from=%s&to=%s' % (self._syncytoken['access_token'], uripaths, uripathd),'','POST','normal')
		if http_code != 200:
			sys.stderr.write('%s ERROR: Copy remote file or directory "%s" to "%s" failed(error code:%d): %s.\n' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), srcpcspath, destpcspath, http_code, self._response_str))
			return 1
		print('%s Copy remote file or directory "%s" to "%s" completed.' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), srcpcspath, destpcspath))
		return 0
	def __rm_localfile(self,delpath,slient = ''):
		try:
			if os.path.isfile(delpath):
				os.remove(delpath)
				if slient == '':
					print('%s Delete local file "%s" completed.' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), delpath))
			elif os.path.isdir(delpath):
				fnlist = os.listdir(delpath)
				for i in xrange(len(fnlist)):
					self.__rm_localfile(delpath + '/' + fnlist[i])
				os.rmdir(delpath)
				print('%s Delete local directory "%s" completed.' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), delpath))
		except os.error:
			sys.stderr.write('%s Delete local directory "%s" failed.\n' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), delpath))
			return 1
		return 0
	def __check_pcspath(self,pcsdirname,pcsfilename):
		if len(pcsdirname) + len(pcsfilename) +1 >= 1000:
			sys.stderr.write('%s ERROR: Length of PCS path(%s/%s) must less than 1000, skip upload.\n' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), pcsdirname, pcsfilename))
			return 1
		if self._re['pcspath'].findall(pcsfilename):
			sys.stderr.write('%s ERROR: PCS path(%s/%s) is invalid, please check whether special characters exists in the path, skip upload the file.\n' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), pcsdirname, pcsfilename))
			return 1
		return 0
	def __compress_data(self,pathname,sydbnew,sydb = None,sydblen = 0):
		fnlist = os.listdir(pathname)
		fnlist.sort()
		for fnname in fnlist:
			if fnname[0:1] == '.':
				continue
			fullpath = pathname + '/' + fnname
			if os.path.isdir(fullpath):
				if self._config['datacache'] == 'on':
					self.__compress_data(fullpath,sydbnew)
				else:
					self.__compress_data(fullpath,sydbnew,sydb,sydblen)
			elif os.path.isfile(fullpath):
				fnstat = os.stat(fullpath)
				md5 = hashlib.md5(fullpath[self._basedirlen:] + '\n').digest()
				prk = struct.pack('>I', int(fnstat.st_mtime)) + struct.pack('>I', fnstat.st_size % 4294967296)
				if self._config['datacache'] == 'on':
					if self._syncData.has_key(md5) and self._syncData[md5][16:]:
						sydbnew.write(self._syncData[md5] + md5)
						del self._syncData[md5]
				else:
					if sydb.tell() == sydblen:
						sydb.seek(0)
					datarec = sydb.read(40)
					readlen = 40
					while datarec and readlen <= sydblen:
						if datarec[16:] == prk + md5:
							sydbnew.write(datarec)
							break
						if readlen == sydblen:
							break
						if sydb.tell() == sydblen: 
							sydb.seek(0)
						datarec = sydb.read(40)
						readlen += 40
		return 0
	def __start_compress(self,pathname = ''):
		if pathname == '':
			mpath = self._config['syncpath'].split(';')
			print("%s Start compress sync data." % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())))
		else:
			mpath = [pathname]
		for ipath in mpath:
			if ipath == '':
				continue
			sypath = ipath.split(':')
			if sypath[2].lower() in ['4','s','sync']:
				continue
			self._basedirlen = len(sypath[0])
			self._syncydb = sypath[0] + '/.syncy.info.db'
			if os.path.exists(self._syncydb):
				self._syncydbtmp = sypath[0] + '/.syncy.info.db1'
				if os.path.exists(self._syncydbtmp):
					os.remove(self._syncydbtmp)
				sydbnew = open(self._syncydbtmp, 'wb')
				if self._config['datacache'] == 'on':
					self.__init_syncdata()
					self.__compress_data(sypath[0],sydbnew)
					del self._syncData
				else:
					sydb = open(self._syncydb, 'rb')
					sydblen = os.stat(self._syncydb).st_size
					self.__compress_data(sypath[0],sydbnew,sydb,sydblen)
					sydb.close()
				sydbnew.close()
				os.rename(self._syncydbtmp,self._syncydb)
		if  pathname == '':
			self._syncytoken['compress_date'] = int(time.time())
			self._syncytoken['synctotal'] = 0
			self.__save_config()
			print("%s Sync data compress completed." % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())))
	def __check_excludefiles(self,filepath):
		for reexf in self._excludefiles:
			if reexf.findall(filepath):
				return 1
		return 0
	def __check_syncstatus(self,rmd5,fmtime,fsize,fmd5):
		if rmd5 != '*':
			rmd5 = rmd5.decode('hex')
		if fmtime != '*':
			if fmtime == -1:
				fmtime = int(time.time())
				print('WARNING: Invalid time, change to %d' % fmtime)
			fmtime = struct.pack('>I',fmtime)
		fsize = struct.pack('>I', fsize % 4294967296)
		if self._config['datacache'] == 'on':
			if not(self._syncData.has_key(fmd5)):
				return 0
			if rmd5 == '*' and self._syncData[fmd5][16:] == fmtime + fsize:
				return 1
			elif fmtime == '*' and self._syncData[fmd5][0:16] + self._syncData[fmd5][20:] == rmd5 + fsize:
				return 1
			elif self._syncData[fmd5] ==  rmd5 + fmtime  + fsize:
				return 1
		else:
			if self._sydb.tell() == self._sydblen:
				self._sydb.seek(0)
			datarec = self._sydb.read(40)
			readlen = 40
			while datarec and readlen <= self._sydblen:
				if rmd5 == '*' and datarec[16:] == fmtime + fsize + fmd5:
					return 1
				elif fmtime == '*' and datarec[0:16] + datarec[20:] == rmd5 + fsize + fmd5:
					return 1
				elif datarec == rmd5 + fmtime + fsize + fmd5:
					return 1
				if readlen == self._sydblen:
					break
				if self._sydb.tell() == self._sydblen: 
					self._sydb.seek(0)
				datarec = self._sydb.read(40)
				readlen += 40
		return 0
	def __get_newname(self,oldname):
		nowtime = str(time.strftime("%Y%m%d%H%M%S", time.localtime()))
		m = self._re['newname'].findall(oldname)
		if m:
			newname = m[0][0] + '_old_' + nowtime + m[0][1]
		else:
			newname = oldname + '_old_' + nowtime
		return newname
	def __syncy_upload(self,ldir,rdir):
		fnlist = os.listdir(ldir)
		fnlist.sort()
		for fi in xrange(len(fnlist)):
			lfullpath = ldir + '/' + fnlist[fi]
			if fnlist[fi][0:1] == '.' or self.__check_excludefiles(lfullpath) == 1 or self.__check_pcspath(rdir,fnlist[fi]) == 1:
				continue
			rfullpath = rdir + '/' + fnlist[fi]
			if os.path.isdir(lfullpath):
				self.__syncy_upload(lfullpath,rfullpath)
			else:
				fmeta = os.stat(lfullpath)
				fnmd5 = hashlib.md5(lfullpath[self._basedirlen:] + '\n').digest()
				if self.__check_syncstatus('*',int(fmeta.st_mtime),fmeta.st_size,fnmd5) == 0:
					if self._config['ondup'] == 'rename':
						ondup = 'newcopy'
					else:
						ondup = 'overwrite'
					if os.path.exists(lfullpath + '.tmp.syy'):
						ret = self.__slice_uploadfile(lfullpath,int(fmeta.st_mtime),fmeta.st_size,rfullpath,fnmd5,ondup)
					else:
						ret = self.__rapid_uploadfile(lfullpath,int(fmeta.st_mtime),fmeta.st_size,rfullpath,fnmd5,ondup)
					if ret == 0:
						self._synccount += 1
					else:
						self._failcount += 1
				else:
					continue
		return 0
	def __syncy_uploadplus(self,ldir,rdir):
		startIdx = 0
		retcode,rfnlist = self.__get_pcs_filelist(rdir,startIdx,self._config['listnumber'])
		if retcode != 0 and retcode != 31066:
			return 1
		lfnlist = os.listdir(ldir)
		lfnlist.sort()
		while retcode == 0:
			for i in xrange(len(rfnlist)):
				rfullpath = self._re['path'].findall(rfnlist[i])[0]
				fnname = os.path.basename(rfullpath)
				lfullpath = ldir + '/' + fnname
				if self.__check_excludefiles(lfullpath) == 1:
					continue
				if os.path.exists(lfullpath):
					for idx in xrange(len(lfnlist)):
						if lfnlist[idx] == fnname:
							del lfnlist[idx]
							break
				else:
					continue
				fnisdir = self._re['isdir'].findall(rfnlist[i])[0]
				if (fnisdir == '1' and os.path.isfile(lfullpath)) or (fnisdir == 0 and os.path.isdir(lfullpath)):
					if self._config['ondup'] == 'rename':
						fnnamenew = rdir + '/' + self.__get_newname(fnname)
						if len(fnnamenew) >= 1000:
							sys.stderr.write('%s ERROR: Rename faild, the length of PCS path "%s" must less than 1000, skip upload "%s".\n' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), fnnamenew, lfullpath))
							self._failcount += 1
							continue
						if self.__mv_pcsfile(rfullpath,fnnamenew) == 1:
							sys.stderr.write('%s ERROR: Rename "%s" failed, skip upload "%s".\n' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), rfullpath, lfullpath))
							self._failcount += 1
							continue
					else:
						self.__rm_pcsfile(rfullpath,'s')
					if os.path.isdir(lfullpath):
						self.__syncy_uploadplus(lfullpath,rfullpath)
						continue
					else:
						fmeta = os.stat(lfullpath)
						fnmd5 = hashlib.md5(lfullpath[self._basedirlen:] + '\n').digest()
						ret = self.__rapid_uploadfile(lfullpath,int(fmeta.st_mtime),fmeta.st_size,rfullpath,fnmd5,'overwrite')
				elif fnisdir == '1':
					self.__syncy_uploadplus(lfullpath,rfullpath)
					continue
				else:
					fmeta = os.stat(lfullpath)
					fnmd5 = hashlib.md5(lfullpath[self._basedirlen:] + '\n').digest()
					rmd5 = self._re['md5'].findall(rfnlist[i])[0]
					rsize = int(self._re['size'].findall(rfnlist[i])[0])
					if fmeta.st_size == rsize:
						if self.__check_syncstatus(rmd5,int(fmeta.st_mtime),rsize,fnmd5) == 1:
							continue
					if self._config['ondup'] == 'rename':
						fnnamenew = rdir + '/' + self.__get_newname(fnname)
						if len(fnnamenew) >= 1000:
							sys.stderr.write('%s ERROR: Rename faild, the length of PCS path "%s" must less than 1000, skip upload "%s".\n' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), fnnamenew, lfullpath))
							self._failcount += 1
							continue
						if self.__mv_pcsfile(rfullpath,fnnamenew) == 1:
							sys.stderr.write('%s ERROR: Rename "%s" failed, skip upload "%s".\n' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), rfullpath, lfullpath))
							self._failcount += 1
							continue
					else:
						self.__rm_pcsfile(rfullpath,'s')
					if os.path.exists(lfullpath + '.tmp.syy'):
						ret = self.__slice_uploadfile(lfullpath,int(fmeta.st_mtime),fmeta.st_size,rfullpath,fnmd5,'overwrite')
					else:
						ret = self.__rapid_uploadfile(lfullpath,int(fmeta.st_mtime),fmeta.st_size,rfullpath,fnmd5,'overwrite')
				if ret == 0:
					self._synccount += 1
				else:
					self._failcount += 1
			if len(rfnlist) < self._config['listnumber']:
				break
			startIdx += self._config['listnumber']
			retcode,rfnlist = self.__get_pcs_filelist(rdir,startIdx,startIdx + self._config['listnumber'])
			if retcode != 0:
				return 1
		for idx in xrange(len(lfnlist)):
			lfullpath = ldir + '/' + lfnlist[idx]
			if lfnlist[idx][0:1] == '.' or self.__check_excludefiles(lfullpath) == 1 or self.__check_pcspath(rdir,lfnlist[idx]) == 1:
				continue
			rfullpath = rdir + '/' + lfnlist[idx]
			if os.path.isdir(lfullpath):
				self.__syncy_uploadplus(lfullpath,rfullpath)
			elif os.path.isfile(lfullpath):
				fmeta = os.stat(lfullpath)
				fnmd5 = hashlib.md5(lfullpath[self._basedirlen:] + '\n').digest()
				if os.path.exists(lfullpath + '.tmp.syy'):
					ret = self.__slice_uploadfile(lfullpath,int(fmeta.st_mtime),fmeta.st_size,rfullpath,fnmd5,'overwrite')
				else:
					ret = self.__rapid_uploadfile(lfullpath,int(fmeta.st_mtime),fmeta.st_size,rfullpath,fnmd5,'overwrite')
				if ret == 0:
					self._synccount += 1
				else:
					self._failcount += 1
		return 0
	def __syncy_download(self,ldir,rdir):
		startIdx = 0
		retcode,rfnlist = self.__get_pcs_filelist(rdir,startIdx,self._config['listnumber'])
		if retcode != 0:
			return 1
		while retcode == 0:
			for i in xrange(len(rfnlist)):
				rfullpath = self._re['path'].findall(rfnlist[i])[0]
				fnname = os.path.basename(rfullpath)
				if self.__check_excludefiles(rfullpath) == 1:
					continue
				fnisdir = self._re['isdir'].findall(rfnlist[i])[0]
				lfullpath = ldir + '/' + fnname
				if fnisdir == '1':
					if os.path.exists(lfullpath) and os.path.isfile(lfullpath):
						if self._config['ondup'] == 'rename':
							fnnamenew = ldir + '/' + self.__get_newname(fnname)
							os.rename(lfullpath,fnnamenew)
						else:
							self.__rm_localfile(lfullpath)
					if not(os.path.exists(lfullpath)):
						os.mkdir(lfullpath)
						pmeta = os.stat(ldir)
						os.lchown(lfullpath,pmeta.st_uid,pmeta.st_gid)
					self.__syncy_download(lfullpath,rfullpath)
				else:
					rmd5 = self._re['md5'].findall(rfnlist[i])[0]
					rsize = int(self._re['size'].findall(rfnlist[i])[0])
					fnmd5 = hashlib.md5(lfullpath[self._basedirlen:] + '\n').digest()
					if not(os.path.exists(lfullpath + '.tmp.syy')):
						if self.__check_syncstatus(rmd5,'*',rsize,fnmd5) == 1:
							continue
						if os.path.exists(lfullpath) and self._config['ondup'] == 'rename':
							fnnamenew = ldir + '/' + self.__get_newname(fnname)
							os.rename(lfullpath,fnnamenew)
						elif os.path.exists(lfullpath):
							self.__rm_localfile(lfullpath)
					ret = self.__download_file(rfullpath,rmd5,rsize,lfullpath,fnmd5)
					if ret == 0:
						self._synccount += 1
					else:
						self._failcount += 1
			if len(rfnlist) < self._config['listnumber']:
				break
			startIdx += self._config['listnumber']
			retcode,rfnlist = self.__get_pcs_filelist(rdir,startIdx,startIdx + self._config['listnumber'])
			if retcode != 0:
				return 1
		return 0
	def __syncy_downloadplus(self,ldir,rdir):
		startIdx = 0
		retcode,rfnlist = self.__get_pcs_filelist(rdir,startIdx,self._config['listnumber'])
		if retcode != 0:
			return 1
		while retcode == 0:
			for i in xrange(len(rfnlist)):
				rfullpath = self._re['path'].findall(rfnlist[i])[0]
				fnname = os.path.basename(rfullpath)
				if self.__check_excludefiles(rfullpath) == 1:
					continue
				fnisdir = self._re['isdir'].findall(rfnlist[i])[0]
				lfullpath = ldir + '/' + fnname
				if fnisdir == '1':
					if os.path.exists(lfullpath) and os.path.isfile(lfullpath):
						if self._config['ondup'] == 'rename':
							fnnamenew = ldir + '/' + self.__get_newname(fnname)
							os.rename(lfullpath,fnnamenew)
						else:
							self.__rm_localfile(lfullpath)
					if not(os.path.exists(lfullpath)):
						os.mkdir(lfullpath)
						pmeta = os.stat(ldir)
						os.lchown(lfullpath,pmeta.st_uid,pmeta.st_gid)
					self.__syncy_downloadplus(lfullpath,rfullpath)
				else:
					fnmd5 = hashlib.md5(lfullpath[self._basedirlen:] + '\n').digest()
					rmd5 = self._re['md5'].findall(rfnlist[i])[0]
					rsize = int(self._re['size'].findall(rfnlist[i])[0])
					if os.path.exists(lfullpath) and not(os.path.exists(lfullpath + '.tmp.syy')):
						fmeta = os.stat(lfullpath)
						if self.__check_syncstatus(rmd5,int(fmeta.st_mtime),rsize,fnmd5) == 1:
							continue
						if self._config['ondup'] == 'rename':
							fnnamenew = ldir + '/' + self.__get_newname(fnname)
							os.rename(lfullpath,fnnamenew)
						else:
							self.__rm_localfile(lfullpath)
					ret = self.__download_file(rfullpath,rmd5,rsize,lfullpath,fnmd5)
					if ret == 0:
						self._synccount += 1
					else:
						self._failcount += 1
			if len(rfnlist) < self._config['listnumber']:
				break
			startIdx += self._config['listnumber']
			retcode,rfnlist = self.__get_pcs_filelist(rdir,startIdx,startIdx + self._config['listnumber'])
			if retcode != 0:
				return 1
		return 0
	def __syncy_sync(self,ldir,rdir):
		startIdx = 0
		retcode,rfnlist = self.__get_pcs_filelist(rdir,startIdx,self._config['listnumber'])
		if retcode != 0 and retcode != 31066:
			return 1
		lfnlist = os.listdir(ldir)
		lfnlist.sort()
		while retcode == 0:
			for i in xrange(len(rfnlist)):
				rfullpath = self._re['path'].findall(rfnlist[i])[0]
				fnname = os.path.basename(rfullpath)
				if self.__check_excludefiles(rfullpath) == 1:
					continue
				lfullpath = ldir + '/' + fnname
				if os.path.exists(lfullpath):
					for idx in xrange(len(lfnlist)):
						if lfnlist[idx] == fnname:
							del lfnlist[idx]
							break
				fnisdir = self._re['isdir'].findall(rfnlist[i])[0]
				rmtime = int(self._re['mtime'].findall(rfnlist[i])[0])
				if fnisdir == '1':
					if os.path.exists(lfullpath) and os.path.isfile(lfullpath):
						fmeta = os.stat(lfullpath)
						fnmd5 = hashlib.md5(lfullpath[self._basedirlen:] + '\n').digest()
						if self.__check_syncstatus('*',int(fmeta.st_mtime),fmeta.st_size,fnmd5) == 1:
							self.__rm_localfile(lfullpath)
							ret = self.__syncy_downloadplus(lfullpath,rfullpath)
							if ret == 0:
								self._synccount += 1
							else:
								self._failcount += 1
							continue
						elif rmtime > int(fmeta.st_mtime):
							self.__rm_localfile(lfullpath)
							ret = self.__syncy_downloadplus(lfullpath,rfullpath)
							if ret == 0:
								self._synccount += 1
							else:
								self._failcount += 1
							continue
						else:
							self.__rm_pcsfile(rfullpath,'s')
							ret = self.__rapid_uploadfile(lfullpath,int(fmeta.st_mtime),fmeta.st_size,rfullpath,fnmd5,'overwrite')
					else:
						if not(os.path.exists(lfullpath)):
							os.mkdir(lfullpath)
							pmeta = os.stat(ldir)
							os.lchown(lfullpath,pmeta.st_uid,pmeta.st_gid)
						self.__syncy_sync(lfullpath,rfullpath)
						continue
				else:
					rmd5 = self._re['md5'].findall(rfnlist[i])[0]
					rsize = int(self._re['size'].findall(rfnlist[i])[0])
					fnmd5 = hashlib.md5(lfullpath[self._basedirlen:] + '\n').digest()
					if os.path.exists(lfullpath) and os.path.isdir(lfullpath):
						if self.__check_syncstatus(rmd5,'*',rsize,fnmd5) == 1:
							self.__rm_pcsfile(rfullpath,'s')
							self.__syncy_uploadplus(lfullpath,rfullpath)
							continue
						else:
							lmtime = int(os.stat(lfullpath).st_mtime)
							if rmtime > lmtime:
								self.__rm_localfile(lfullpath)
								ret = self.__download_file(rfullpath,rmd5,rsize,lfullpath,fnmd5)
							else:
								self.__rm_pcsfile(rfullpath,'s')
								self.__syncy_uploadplus(lfullpath,rfullpath)
								continue
					elif os.path.exists(lfullpath):
						fmeta = os.stat(lfullpath)
						if rsize == fmeta.st_size and self.__check_syncstatus(rmd5,int(fmeta.st_mtime),fmeta.st_size,fnmd5) == 1:
							continue
						elif self.__check_syncstatus('*',int(fmeta.st_mtime),fmeta.st_size,fnmd5) == 1:
							self.__rm_localfile(lfullpath)
							ret = self.__download_file(rfullpath,rmd5,rsize,lfullpath,fnmd5)
							if ret == 0:
								self._synccount += 1
							else:
								self._failcount += 1
							continue
						if self.__check_syncstatus(rmd5,'*',rsize,fnmd5) == 1:
							self.__rm_pcsfile(rfullpath,'s')
							ret = self.__rapid_uploadfile(lfullpath,int(fmeta.st_mtime),fmeta.st_size,rfullpath,fnmd5,'overwrite')
						elif os.path.exists(lfullpath + '.tmp.syy'):
							infoh = open(lfullpath + '.tmp.syy','r')
							syyinfo = infoh.readline()
							infoh.close()
							if syyinfo.strip('\n') == 'download ' + rmd5 + ' ' + str(rsize):
								ret = self.__download_file(rfullpath,rmd5,rsize,lfullpath,fnmd5)
							else:
								os.remove(lfullpath + '.tmp.syy')
								if rmtime > int(fmeta.st_mtime):
									self.__rm_localfile(lfullpath)
									ret = self.__download_file(rfullpath,rmd5,rsize,lfullpath,fnmd5)
								else:
									self.__rm_pcsfile(rfullpath)
									ret = self.__rapid_uploadfile(lfullpath,int(fmeta.st_mtime),fmeta.st_size,rfullpath,fnmd5,'overwrite')
						elif rmtime > int(fmeta.st_mtime):
							self.__rm_localfile(lfullpath)
							ret = self.__download_file(rfullpath,rmd5,rsize,lfullpath,fnmd5)
						else:
							self.__rm_pcsfile(rfullpath)
							ret = self.__rapid_uploadfile(lfullpath,int(fmeta.st_mtime),fmeta.st_size,rfullpath,fnmd5,'overwrite')
					else:
						if self.__check_syncstatus(rmd5,'*',rsize,fnmd5) == 1:
							ret = self.__rm_pcsfile(rfullpath)
						else:
							ret = self.__download_file(rfullpath,rmd5,rsize,lfullpath,fnmd5)
				if ret == 0:
					self._synccount += 1
				else:
					self._failcount += 1
			if len(rfnlist) < self._config['listnumber']:
				break
			startIdx += self._config['listnumber']
			retcode,rfnlist = self.__get_pcs_filelist(rdir,startIdx,startIdx + self._config['listnumber'])
			if retcode != 0:
				return 1
		for idx in xrange(len(lfnlist)):
			lfullpath = ldir + '/' + lfnlist[idx]
			if lfnlist[idx][0:1] == '.' or self.__check_excludefiles(lfullpath) == 1 or self.__check_pcspath(rdir,lfnlist[idx]) == 1:
				continue
			rfullpath = rdir + '/' + lfnlist[idx]
			if os.path.isdir(lfullpath):
				self.__syncy_sync(lfullpath,rfullpath)
				dir_files = os.listdir(ldir)
				if len(dir_files) == 0:
					os.rmdir(lfullpath)
			elif os.path.isfile(lfullpath):
				fmeta = os.stat(lfullpath)
				fnmd5 = hashlib.md5(lfullpath[self._basedirlen:] + '\n').digest()
				if self.__check_syncstatus('*',int(fmeta.st_mtime),fmeta.st_size,fnmd5) == 1:
					ret = self.__rm_localfile(lfullpath)
				elif os.path.exists(lfullpath + '.tmp.syy'):
					infoh = open(lfullpath + '.tmp.syy','r')
					syyinfo = infoh.readline()
					infoh.close()
					if syyinfo.strip('\n') == 'upload ' + str(int(fmeta.st_mtime)) + ' ' + str(fmeta.st_size):
						ret = self.__slice_uploadfile(lfullpath,int(fmeta.st_mtime),fmeta.st_size,rfullpath,fnmd5,'overwrite')
					else:
						os.remove(lfullpath + '.tmp.syy')   
						ret = self.__rapid_uploadfile(lfullpath,int(fmeta.st_mtime),fmeta.st_size,rfullpath,fnmd5,'overwrite')
				else:
					ret = self.__rapid_uploadfile(lfullpath,int(fmeta.st_mtime),fmeta.st_size,rfullpath,fnmd5,'overwrite')
				if ret == 0:
					self._synccount += 1
				else:
					self._failcount += 1
		return 0
	def __start_syncy(self):
		self.__get_pcs_quota()
		for i in range(len(self._syncpath)):
			if not(self._syncpath[str(i)].has_key("localpath")) or not(self._syncpath[str(i)].has_key("remotepath")) or not(self._syncpath[str(i)].has_key("synctype")) or not(self._syncpath[str(i)].has_key("enable")):
				sys.stderr.write('%s ERROR: The %d\'s of syncpath setting is invalid.\n' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), i+1))
				continue
			if self._syncpath[str(i)]['enable'] == '0':
				continue
			self._synccount = 0
			self._failcount = 0
			self._errorcount = 0
			ipath = ('%s:%s:%s' % (self._syncpath[str(i)]['localpath'], self._syncpath[str(i)]['remotepath'], self._syncpath[str(i)]['synctype']))
			print('%s Start sync path: "%s".' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), ipath))
			localpath = self.__catpath(self._syncpath[str(i)]['localpath'])
			remotepath = self.__catpath(self._pcsroot, self._syncpath[str(i)]['remotepath'])
			ckdir = 0
			for rdir in remotepath.split('/'):
				if self._re['pcspath'].findall(rdir):
					ckdir = 1
					break
			if ckdir != 0:
				sys.stderr.write('%s ERROR: Sync "%s" failed, remote directory error.\n' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), ipath))
				continue
			if not(os.path.exists(localpath)):
				os.mkdir(localpath)
				pmeta = os.stat(os.path.dirname(localpath))
				os.lchown(localpath,pmeta.st_uid,pmeta.st_gid)
			if localpath != '' and os.path.isdir(localpath):
				self._syncydb = localpath + '/.syncy.info.db'
				if self._config['datacache'] == 'on':
					self.__init_syncdata()
				else:
					self._sydblen = os.stat(self._syncydb).st_size
					self._sydb = open(self._syncydb,'rb')
				self._basedirlen = len(localpath)
				if self._syncpath[str(i)]['synctype'].lower() in ['0','u','upload']:
					self.__syncy_upload(localpath,remotepath)
				elif self._syncpath[str(i)]['synctype'].lower() in ['1','u+','upload+']:
					self.__syncy_uploadplus(localpath,remotepath)
				elif self._syncpath[str(i)]['synctype'].lower() in ['2','d','download']:
					self.__syncy_download(localpath,remotepath)
					self._syncytoken['synctotal'] += self._synccount
					self.__save_config()
				elif self._syncpath[str(i)]['synctype'].lower() in ['3','d+','download+']:
					self.__syncy_downloadplus(localpath,remotepath)
				elif self._syncpath[str(i)]['synctype'].lower() in ['4','s','sync']:
					self.__syncy_sync(localpath,remotepath)
				else:
					sys.stderr.write('%s Error: The "synctype" of "%s" is invalid, must set to [0 - 4], skiped.\n' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), ipath))
					print('%s Error: The "synctype" of "%s" is invalid, must set to [0 - 4], skiped.' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), ipath))
					continue
				if self._config['datacache'] == 'on':
					del self._syncData
				else:
					self._sydb.close()
				if self._failcount == 0 and self._errorcount == 0:
					if not(self._syncpath[str(i)]['synctype'].lower() in ['2','d','download']):
						self.__start_compress(ipath)
					print('%s Sync path: "%s" complete, Success sync %d files.' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), ipath, self._synccount))
				else:
					print('%s Sync path: "%s" failed, %d files success, %d files failed, %d errors occurred.' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), ipath, self._synccount, self._failcount, self._errorcount))
					sys.stderr.write('%s ERROR: Sync path: "%s" failed, %d files success, %d files failed, %d errors occurred.\n' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), ipath, self._synccount, self._failcount, self._errorcount))
			else:
				sys.stderr.write('%s ERROR: Sync "%s" failed, local directory is not exist or is normal file.\n' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), ipath))
				print('%s ERROR: Sync "%s" failed, local directory is not exist or is normal file.' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), ipath))
		self.__get_pcs_quota()
		del self._response_str
	@staticmethod
	def __test_chinese(tdir = ''):
		unicode_str = '\u4e2d\u6587\u8f6c\u7801\u6d4b\u8bd5'
		unicode_str = eval('u"' + unicode_str + '"')
		unicode_str = unicode_str.encode('utf8')
		chnfn = open(tdir + '/' + unicode_str, 'w')
		chnfn.write(unicode_str)
		chnfn.close()
	def __data_convert(self):
		mpath = self._config['syncpath'].split(';')
		for i in range(len(mpath)):
			if mpath[i] == '':
				continue
			localdir = mpath[i].split(':')[0:1]
			syncydb = localdir + '/.syncy.info.db'
			if os.path.exists(syncydb):
				syncydbtmp = localdir + '/.syncy.info.db1'
				if os.path.exists(syncydbtmp):
					os.remove(syncydbtmp)
				sydb = open(syncydb,'r')
				syncInfo = sydb.readlines()
				sydb.close()
				if len(syncInfo[0]) > 100 or len(syncInfo[0].split(' ')[0]) != 32:
					sys.stderr.write('%s Convert sync data failed "%s".\n' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), mpath[i]))
					continue
				sydbnew = open(syncydbtmp,'wb')
				for j in xrange(len(syncInfo)):
					rmd5,lmtime,lsize,lmd5 = syncInfo[j].split(' ')
					rmd5 = rmd5.decode('hex')
					lmtime = struct.pack('>I',lmtime)
					lsize = struct.pack('>I', lsize % 4294967296)
					lmd5 = lmd5.decode('hex')
					sydbnew.write(rmd5 + lmtime + lsize + lmd5)
				sydbnew.close()
				os.rename(syncydbtmp,syncydb)
	def sync(self):
		if len(self._argv) == 0:
			if self._config['syncperiod'] == '':
				self.__start_syncy()
			else:
				starthour,endhour = self._config['syncperiod'].split('-')
				curhour = time.localtime().tm_hour
				if starthour == '' or endhour == '' or int(starthour) < 0 or int(starthour) >23 or int(endhour) <0 or int(endhour) >24 or endhour == starthour:
					print('%s WARNING: "syncperiod" is invalid, set to default(0-24).\n' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())))
					self._config['syncperiod'] = '0-24'
					starthour = 0
					endhour = 24
				starthour = int(starthour)
				endhour = int(endhour)
				while True:
					if (endhour > starthour and curhour >= starthour and curhour < endhour) or (endhour < starthour and (curhour < starthour or curhour >= endhour)):
						self.__start_syncy()
						time.sleep(self._config['syncinterval'])
						if (self._syncytoken['refresh_date'] + self._syncytoken['expires_in'] - 864000) < int(time.time()):
							self.__check_expires()
					else:
						time.sleep(300)
					curhour = time.localtime().tm_hour
		elif self._argv[0] == 'compress':
			self.__start_compress()
		elif self._argv[0] == 'convert':
			self.__data_convert()
		elif self._argv[0] == 'testchinese':
			self.__test_chinese(self._argv[1])
		elif os.path.isfile(self._argv[0]):
			fname = os.path.basename(self._argv[0])
			if len(self._argv) == 2:
				pcsdir = self.__catpath(self._pcsroot, self._argv[1])
			else:
				pcsdir = self._pcsroot
			if self.__check_pcspath(pcsdir,fname) == 0:
				self.__upload_file_nosync(self._argv[0], self.__catpath(pcsdir, fname))
		elif not(self._argv[0] in ["sybind","cpbind"]):
			print('%s Unknown command "%s"' % (time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), ' '.join(self._argv)))
sy = SyncY(sys.argv[1:])
sy.sync()
sys.exit(0)
