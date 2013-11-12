require 'net/http'
require 'openssl'
require 'json'
require 'digest/sha1'
require 'uri'
require 'base64'
#require 'iconv'
require_relative 'weibo'
class Weibo
	def LoginByPassword(uname,pwd)
		logindata={'entry'=>'weibo', 'gateway'=>'1',
			'from'=>'', 'savestate'=>'7', 'userticket'=>'1',
			'ssosimplelogin'=>'1', 'vsnf'=>'1', 'su'=>'', 
			'service'=>'miniblog', 'servertime'=>'', 'nonce'=>'',
			'pwencode'=>'rsa2', 'rsakv'=>'', 'sp'=>'',
			'encoding'=>'UTF-8', 'prelt'=>'115',
			'returntype'=>'META',
			'url'=>'http://weibo.com/ajaxlogin.php?framelogin=1&callback=parent.sinaSSOController.feedBackUrlCallBack'
		}

		#pre login
		preloginurl = 'http://login.sina.com.cn/sso/prelogin.php?entry=sso&' +
			'callback=sinaSSOController.preloginCallBack&su=' + 
			'dW5kZWZpbmVk' + '&rsakt=mod&client=ssologin.js(v1.4.2)' + 
				 "&_=" + Time.now.to_i.to_s
		#puts preloginurl
		res = HttpGet(preloginurl)
		keys = res.body[/\{\"retcode[^\0]*\}/]
		return false if keys == nil
		keys = JSON.parse(keys)
		return false if keys == nil
		return false if keys['retcode'] != 0

		logindata['servertime'] = keys['servertime'] 
		logindata['nonce'] =  keys['nonce'] 
		logindata['rsakv'] =  keys['rsakv'] 
		logindata['su'] = Base64.strict_encode64(uname.sub("@","%40"))
		#puts uname + ":" + logindata['su']
		pwdkey = keys['servertime'].to_s + "\t" + keys['nonce'].to_s + "\n" + pwd.to_s

		pub = OpenSSL::PKey::RSA::new
		pub.e = 65537
		pub.n = OpenSSL::BN.new(keys['pubkey'],16)
		logindata['sp'] = pub.public_encrypt(pwdkey).unpack('H*').first

		uri = 'http://login.sina.com.cn/sso/login.php?client=ssologin.js(v1.4.2)'
		hdrs = {
			'Refere' => 'http://weibo.com/login.php',
			'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
			'Connection' => 'keep-alive'
		}
		res = HttpPost(uri,logindata,hdrs)
		#puts 'save cookie'
		redrecturi = res.body[/http:\/\/weibo.com\/ajax[^'"]*/]
		retcode = redrecturi.match(/retcode=([\d]+)/)
		retcode = retcode[1] if retcode != nil
		return false if redrecturi == nil
		retcode = retcode.to_s
		if retcode.to_s != '0'
			reason = redrecturi.match(/reason=([^&]+)/)
			reason = reason[1] if reason != nil
			reason = URI.unescape(reason)
			#reason = @iconvFromGB2312.iconv(reason)
			#puts reason
		end
		p "===========#{retcode}"
		return retcode if retcode != '0'
		# return false if !@cookies.GetCookie('SUP','sina.com.cn')
		res = HttpGet(redrecturi)
		ujson = res.body[/\{\"result\"\:[^)]+\}/]
		p "------------"
		return false if ujson == nil
		rval = JSON.parse(ujson);
		p "+++++++++++"
		return false if rval.has_key?('userinfo') == false
		return false if rval.has_key?('result') == false
		return false if rval['result'] == false
		@userInfo = rval['userinfo']
		HttpGet('http://weibo.com/login.php');
		return true
	end
	def LoginByCookie(cks)
		if cks != nil
			@cookies.Import(cks)
			HttpGet('http://weibo.com')
			return  true if @cookies.GetCookie('SUP','sina.com.cn') != nil
		end
		return false
	end
	def GetCookie(ckn)
		return @cookies.GetCookie(ckn,'weibo.com')
	end
	def ExportCookie()
		return @cookies.Export()
	end
end
if __FILE__ == $0
wb =  Weibo.new
if wb.LoginByPassword("alist8261180@sina.cn","exam5100") != true
	puts 'login fail!'
else
	puts 'login success!'
	cks = wb.ExportCookie()
	if cks != nil
		if wb.LoginByCookie(cks) != true
			puts 'cookie login fail!'
		else
			puts 'cookie login success!'
		end
	end
end
end

