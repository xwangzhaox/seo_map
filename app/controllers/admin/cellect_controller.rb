require 'nokogiri'
require 'open-uri'

class Admin::CellectController < ApplicationController
  layout "admin"
  
  def index
    
    @url = "http://weibo.com/u/1177593412?sudaref=www.sina.com.cn"
    # page = Nokogiri::HTML(open(url))
    
    # @news_links = page.css("body a").to_html
    # news_links.each{|d| puts d["id"]}
    # p news_links.size

  end
end
