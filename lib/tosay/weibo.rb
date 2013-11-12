require 'net/http'
require 'openssl'
require 'json'
require 'digest/sha1'
require 'uri'
require 'base64'
# require 'iconv'
require_relative 'cookie'

class Weibo
	def initialize()
		@cookies = Cookie.new()
		@UserAgent = 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:14.0) Gecko/20100101 Firefox/14.0.1'
		#@iconvFromGB2312=Iconv.new('UTF-8','GB2312') 
	end
	def HttpGet(url,limit=10,hdrs=nil)
		raise ArgumentError, 'too many HTTP redirects' if limit == 0
		uri = URI(url)
		ck = @cookies.GetDomainCookie(uri.host)
		req = Net::HTTP::Get.new(uri.request_uri)

		req['User-Agent'] = @UserAgent
		if hdrs != nil 
			hdrs.each do |key,val|
				req[key] = val
			end
		end
		req['Cookie'] = ck if ck != nil

		res = Net::HTTP.start(uri.host, uri.port) do |http|
			http.request(req)
		end
		@cookies.SaveCookie(uri.host,res.to_hash['set-cookie']) 
		if res.kind_of?(Net::HTTPRedirection) 
			newurl = res['location'] 
			newurl = newurl.sub(/^\//,'http://'+uri.host+'/')
			HttpGet(newurl,limit-1) 
		end
		return res
	end
	def HttpPost(url,pdata,hdrs=nil)
		uri = URI(url)
		ck = @cookies.GetDomainCookie(uri.host)
		req = Net::HTTP::Post.new(uri.request_uri)
		req['User-Agent'] = @UserAgent
		req['Content-Type'] = 'application/x-www-form-urlencoded'
		if hdrs != nil 
			hdrs.each do |key,val|
				req[key] = val
			end
		end
		req['Cookie'] = ck if ck != nil
		req.set_form_data(pdata)
		res = Net::HTTP.start(uri.host, uri.port) do |http|
			http.request(req)
		end
		@cookies.SaveCookie(uri.host,res.to_hash['set-cookie']) 
		return res
	end

end
