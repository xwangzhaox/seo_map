class Cookie
	def initialize()
		@cookies = Hash.new
	end
	def GetCookie(name,domain=nil)
		if domain == nil
			@cookies.each do |key,val|
				return val[name] if  val.has_key?(name)
			end
		else
			return nil if @cookies.has_key?(domain) == false
			return @cookies[domain][name]
		end
		return nil
	end
	def GetDomainCookie(domain)
		#domain = domain.sub(/^\./,'')
		ck = ''
		domain= domain.sub(/^\./,'')
		domarry= domain.split('.')
		dom= domarry.last
		domarry.delete_at(domarry.length-1)
		domarry.reverse_each do |x|
			next if x==nil
			next if x.length == 0
			dom = x +  '.' + dom
			next if @cookies.has_key?(dom) == false
			@cookies[dom].each do |key,val|
				ck = ck + key + '=' + val + '; '
			end
		end	
		ck = ck.chomp('; ') 
		return nil if ck.length == 0
		return ck
	end
	def SetCookie(domain,ckn,ckv)
		@cookies[domain] = Hash.new  if @cookies.has_key?(domain) == false
		@cookies[domain][ckn] = ckv
	end
	def Export()
		return @cookies.to_json
	end
	def Import(cks)

	end
	def PrintCookies()
		puts JSON.pretty_generate(@cookies)
		#puts @cookies.to_json
	end
	def SaveCookie(domain,ck)
		return if ck == nil
		ck.each do |cks|
			ckis = cks.split(';')
			next if ckis == nil
			next if ckis.length <= 0
			cdom = domain
			ckis.each do |x|
				x = x.sub(/^ /,'')
				val = x.split('=')
				cdom  = val[1] if val[0] == 'domain'
			end
			cdom = cdom.sub(/^\./,'')
			ckname, *ckval = ckis[0].split('=')
			next if ckname == nil
			next if ckval  == nil 
			ckval = ckval.join('=')
			#puts ckname +":" +  "  " + cdom
			@cookies[cdom] = Hash.new  if @cookies.has_key?(cdom) == false
			if ckval == 'deleted' 
				@cookies[cdom].delete(ckname)
			elsif
				@cookies[cdom][ckname] = ckval
			end
		end
	end
end

