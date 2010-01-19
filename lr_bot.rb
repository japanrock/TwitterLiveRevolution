#!/usr/bin/env ruby
# coding: utf-8

require 'rubygems'
require 'oauth'
require 'json'
require 'hpricot'
require 'open-uri'


# トークンセット
CONSUMER_KEY = 'BNKnGRJvipUp4dk079AqTA'
CONSUMER_SECRET = 'MOhm85LWqXho2seF1AyAWwfaZ7BCGYjcKcOEdeiZs'
ACCESS_TOKEN = '98119957-JafcWurUIeFoh65Pr9c9Eph3mwSkWGhf0ivAfdPrM'
ACCESS_TOKEN_SECRET = 'XwlX9CcQS0ZtNaUBDwbqOX8O6zmROcFdn0JZpNOY'

# オブジェクト生成
consumer = OAuth::Consumer.new(
  CONSUMER_KEY,
  CONSUMER_SECRET,
  :site => 'http://twitter.com'
)
access_token = OAuth::AccessToken.new(
  consumer,
  ACCESS_TOKEN,
  ACCESS_TOKEN_SECRET
)

# Base
base_url        = "http://www.live-revolution.co.jp"                                              # リクトモのベースURL
lr_news_feed    = Hpricot(open("#{base_url}/atom_0093news.xml"))    # リクトモの新着・更新日記を取得
adc_news_feed = http://www.live-revolution.co.jp/atom_0060adc_news.xml

#パース

diary_list      = doc.search("//div[@id='article_title_in_list']")                  # タイトルとリンクを取得のためのパース
diary_time_list = doc.search("//div[@id='article_information_in_list']")            # 時間を取得のためのパース
diaries         = {}                                                                # 日記のタイトル、リンク、時間を入れる箱


# タイトルとリンクを取得
count = 0
diary_list.each do |diary|
  doc = Hpricot(diary.inner_html)
  
  # http://ruby.g.hatena.ne.jp/garyo/20061207/1165477582
  hrefs  = (doc/:a).map {|elem| elem[:href]}

  # title,link
  hrefs.each do |link|
    diaries[count] = ["#{(doc/'a').inner_html}","#{base_url}#{link}"]
  end

  count = count + 1
end


# 日記の時間を取得
count = 0
diary_time_list.each do |time|
  doc = Hpricot(time.inner_html)
  # 09月08日02:57 => 20099080257
  diaries[count] << "#{(doc).inner_html.gsub(/ |月|日|:/, '')}"     # title,link,更新時間
  count = count + 1
end


# 更新日時が今から１時間以内なら、Twitterにポスト
now = Time.new
an_hour_ago = now - 3600

count.times do |i|
  if diaries[i][2].gsub(/\n/,'').to_i > an_hour_ago.strftime("%m%d%H%M").to_i
     response = access_token.post(
      'http://twitter.com/statuses/update.json',
      'status'=> "#{diaries[i][0]} #{diaries[i][1]}"
    )
  end
end

